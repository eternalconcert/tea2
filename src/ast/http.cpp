#include <algorithm>
#include <cctype>
#include <cstring>
#include <map>
#include <netdb.h>
#include <netinet/in.h>
#include <sstream>
#include <string>
#include <sys/socket.h>
#include <unistd.h>
#include <vector>

#include "ast.h"
#include "../exceptions.h"
#include "../value.h"

static char* copyString(const std::string &value) {
    char *copy = new char[value.size() + 1];
    memcpy(copy, value.data(), value.size());
    copy[value.size()] = '\0';
    return copy;
}

static std::string lowerString(std::string value) {
    std::transform(value.begin(), value.end(), value.begin(), [](unsigned char c) {
        return std::tolower(c);
    });
    return value;
}

static std::string trimString(const std::string &value) {
    size_t start = 0;
    while (start < value.size() && std::isspace((unsigned char)value[start])) {
        start++;
    }
    size_t end = value.size();
    while (end > start && std::isspace((unsigned char)value[end - 1])) {
        end--;
    }
    return value.substr(start, end - start);
}

static Value* stringValue(const std::string &value, YYLTYPE location) {
    Value *result = new Value();
    result->set(value, location);
    return result;
}

static Value* intValue(int value, YYLTYPE location) {
    Value *result = new Value();
    result->set(value, location);
    return result;
}

static Value* dictValue(const std::map<std::string, Value*> &value, YYLTYPE location) {
    Value *result = new Value();
    result->set(value, location);
    return result;
}

static Value* resolveIfIdentifier(AstNode *scope, Value *value, YYLTYPE location) {
    if (value->type == IDENTIFIER) {
        return getFromValueStore(scope, value->identValue, location);
    }
    return value;
}

static Value* evaluateExpression(AstNode *expression, AstNode *scope, YYLTYPE location) {
    ExpressionNode *eval = (ExpressionNode*)expression;
    eval->evaluate();
    return resolveIfIdentifier(scope, eval->value, location);
}

static Value* dictGet(Value *dict, const std::string &key) {
    auto it = dict->dictValue.find(key);
    if (it == dict->dictValue.end()) {
        return nullptr;
    }
    return it->second;
}

static std::string dictGetString(Value *dict, const std::string &key, const std::string &fallback, YYLTYPE location) {
    Value *value = dictGet(dict, key);
    if (value == nullptr) {
        return fallback;
    }
    if (value->getTrueType() != STR) {
        throw TypeError("HTTP field '" + key + "' must be a string", location);
    }
    return std::string(value->stringValue, value->stringLength);
}

static int dictGetInt(Value *dict, const std::string &key, int fallback, YYLTYPE location) {
    Value *value = dictGet(dict, key);
    if (value == nullptr) {
        return fallback;
    }
    if (value->getTrueType() != INT) {
        throw TypeError("HTTP field '" + key + "' must be an int", location);
    }
    return value->intValue;
}

static std::map<std::string, std::string> dictGetHeaders(Value *dict, YYLTYPE location) {
    std::map<std::string, std::string> headers;
    Value *headersValue = dictGet(dict, "headers");
    if (headersValue == nullptr) {
        return headers;
    }
    if (headersValue->getTrueType() != DICT) {
        throw TypeError("HTTP field 'headers' must be a dict", location);
    }
    for (auto const& item : headersValue->dictValue) {
        if (item.second->getTrueType() != STR) {
            throw TypeError("HTTP header values must be strings", location);
        }
        headers[item.first] = std::string(item.second->stringValue, item.second->stringLength);
    }
    return headers;
}

static std::map<std::string, Value*> headersToTeaDict(const std::map<std::string, std::string> &headers, YYLTYPE location) {
    std::map<std::string, Value*> result;
    for (auto const& item : headers) {
        result[item.first] = stringValue(item.second, location);
    }
    return result;
}

struct ParsedUrl {
    std::string host;
    std::string port;
    std::string target;
    std::string error;
};

static ParsedUrl parseHttpUrl(const std::string &url) {
    ParsedUrl parsed;
    std::string prefix = "http://";
    if (url.rfind(prefix, 0) != 0) {
        parsed.error = "Only http:// URLs are supported";
        return parsed;
    }

    std::string rest = url.substr(prefix.size());
    size_t pathStart = rest.find('/');
    std::string hostPort = pathStart == std::string::npos ? rest : rest.substr(0, pathStart);
    parsed.target = pathStart == std::string::npos ? "/" : rest.substr(pathStart);
    if (hostPort.empty()) {
        parsed.error = "URL host is empty";
        return parsed;
    }

    size_t portStart = hostPort.rfind(':');
    if (portStart == std::string::npos) {
        parsed.host = hostPort;
        parsed.port = "80";
    } else {
        parsed.host = hostPort.substr(0, portStart);
        parsed.port = hostPort.substr(portStart + 1);
    }
    if (parsed.host.empty() || parsed.port.empty()) {
        parsed.error = "URL host or port is empty";
    }
    return parsed;
}

static int connectToHost(const std::string &host, const std::string &port) {
    struct addrinfo hints;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    struct addrinfo *addresses = nullptr;
    if (getaddrinfo(host.c_str(), port.c_str(), &hints, &addresses) != 0) {
        return -1;
    }

    int socketFd = -1;
    for (struct addrinfo *addr = addresses; addr != nullptr; addr = addr->ai_next) {
        socketFd = socket(addr->ai_family, addr->ai_socktype, addr->ai_protocol);
        if (socketFd < 0) {
            continue;
        }
        if (connect(socketFd, addr->ai_addr, addr->ai_addrlen) == 0) {
            break;
        }
        close(socketFd);
        socketFd = -1;
    }

    freeaddrinfo(addresses);
    return socketFd;
}

static bool hasHeader(const std::map<std::string, std::string> &headers, const std::string &name) {
    std::string lowerName = lowerString(name);
    for (auto const& item : headers) {
        if (lowerString(item.first) == lowerName) {
            return true;
        }
    }
    return false;
}

static std::string readAllFromSocket(int socketFd) {
    std::string response;
    char buffer[4096];
    while (true) {
        ssize_t received = recv(socketFd, buffer, sizeof(buffer), 0);
        if (received <= 0) {
            break;
        }
        response.append(buffer, received);
    }
    return response;
}

static Value* makeHttpResponse(int status, const std::string &body, const std::map<std::string, std::string> &headers, const std::string &error, YYLTYPE location) {
    std::map<std::string, Value*> response;
    response["status"] = intValue(status, location);
    response["body"] = stringValue(body, location);
    response["headers"] = dictValue(headersToTeaDict(headers, location), location);
    response["error"] = stringValue(error, location);
    return dictValue(response, location);
}

static Value* parseClientResponse(const std::string &raw, YYLTYPE location) {
    size_t headerEnd = raw.find("\r\n\r\n");
    size_t separatorSize = 4;
    if (headerEnd == std::string::npos) {
        headerEnd = raw.find("\n\n");
        separatorSize = 2;
    }
    if (headerEnd == std::string::npos) {
        return makeHttpResponse(0, raw, {}, "HTTP response did not contain headers", location);
    }

    std::string headerText = raw.substr(0, headerEnd);
    std::string body = raw.substr(headerEnd + separatorSize);
    std::istringstream stream(headerText);
    std::string statusLine;
    std::getline(stream, statusLine);
    statusLine = trimString(statusLine);

    int status = 0;
    std::istringstream statusStream(statusLine);
    std::string httpVersion;
    statusStream >> httpVersion >> status;

    std::map<std::string, std::string> headers;
    std::string line;
    while (std::getline(stream, line)) {
        line = trimString(line);
        if (line.empty()) {
            continue;
        }
        size_t colon = line.find(':');
        if (colon == std::string::npos) {
            continue;
        }
        std::string key = lowerString(trimString(line.substr(0, colon)));
        std::string value = trimString(line.substr(colon + 1));
        headers[key] = value;
    }

    return makeHttpResponse(status, body, headers, "", location);
}

HttpNode::HttpNode(AstNode *requestExpression, AstNode *scope) : ExpressionNode(scope) {
    this->requestExpression = requestExpression;
    this->scope = scope;
}

AstNode* HttpNode::evaluate() {
    Value *request = evaluateExpression(this->requestExpression, this->scope, this->location);
    if (request->getTrueType() != DICT) {
        throw TypeError("http() expects a dict", this->location);
    }

    std::string method = dictGetString(request, "method", "GET", this->location);
    std::string url = dictGetString(request, "url", "", this->location);
    Value *bodyValue = dictGet(request, "body");
    std::string body;
    if (bodyValue != nullptr) {
        if (bodyValue->getTrueType() != STR) {
            throw TypeError("HTTP field 'body' must be a string", this->location);
        }
        body = std::string(bodyValue->stringValue, bodyValue->stringLength);
    }
    std::map<std::string, std::string> headers = dictGetHeaders(request, this->location);

    std::transform(method.begin(), method.end(), method.begin(), [](unsigned char c) {
        return std::toupper(c);
    });

    ParsedUrl parsed = parseHttpUrl(url);
    if (!parsed.error.empty()) {
        this->value = makeHttpResponse(0, "", {}, parsed.error, this->location);
        return this->getNext();
    }

    int socketFd = connectToHost(parsed.host, parsed.port);
    if (socketFd < 0) {
        this->value = makeHttpResponse(0, "", {}, "Could not connect to " + parsed.host + ":" + parsed.port, this->location);
        return this->getNext();
    }

    std::ostringstream requestText;
    requestText << method << " " << parsed.target << " HTTP/1.1\r\n";
    if (!hasHeader(headers, "Host")) {
        requestText << "Host: " << parsed.host << "\r\n";
    }
    if (!hasHeader(headers, "User-Agent")) {
        requestText << "User-Agent: tea\r\n";
    }
    if (!hasHeader(headers, "Connection")) {
        requestText << "Connection: close\r\n";
    }
    for (auto const& item : headers) {
        requestText << item.first << ": " << item.second << "\r\n";
    }
    if (!body.empty() || method == "POST" || method == "PUT" || method == "PATCH") {
        requestText << "Content-Length: " << body.size() << "\r\n";
    }
    requestText << "\r\n" << body;

    std::string payload = requestText.str();
    const char *data = payload.c_str();
    size_t remaining = payload.size();
    while (remaining > 0) {
        ssize_t sent = send(socketFd, data, remaining, 0);
        if (sent <= 0) {
            close(socketFd);
            this->value = makeHttpResponse(0, "", {}, "Could not send HTTP request", this->location);
            return this->getNext();
        }
        data += sent;
        remaining -= sent;
    }

    std::string rawResponse = readAllFromSocket(socketFd);
    close(socketFd);
    this->value = parseClientResponse(rawResponse, this->location);
    return this->getNext();
}

static size_t findHeaderEnd(const std::string &request) {
    size_t end = request.find("\r\n\r\n");
    if (end != std::string::npos) {
        return end + 4;
    }
    end = request.find("\n\n");
    if (end != std::string::npos) {
        return end + 2;
    }
    return std::string::npos;
}

static int contentLengthFromHeaderText(const std::string &headerText) {
    std::istringstream stream(headerText);
    std::string line;
    while (std::getline(stream, line)) {
        size_t colon = line.find(':');
        if (colon == std::string::npos) {
            continue;
        }
        std::string key = lowerString(trimString(line.substr(0, colon)));
        if (key == "content-length") {
            return std::stoi(trimString(line.substr(colon + 1)));
        }
    }
    return 0;
}

static std::string readHttpRequest(int clientFd) {
    std::string request;
    char buffer[4096];
    size_t headerEnd = std::string::npos;
    int contentLength = 0;

    while (true) {
        ssize_t received = recv(clientFd, buffer, sizeof(buffer), 0);
        if (received <= 0) {
            break;
        }
        request.append(buffer, received);
        if (headerEnd == std::string::npos) {
            headerEnd = findHeaderEnd(request);
            if (headerEnd != std::string::npos) {
                contentLength = contentLengthFromHeaderText(request.substr(0, headerEnd));
            }
        }
        if (headerEnd != std::string::npos && request.size() >= headerEnd + (size_t)contentLength) {
            break;
        }
    }
    return request;
}

static Value* parseServerRequest(const std::string &raw, YYLTYPE location) {
    size_t headerEnd = findHeaderEnd(raw);
    std::string headerText = headerEnd == std::string::npos ? raw : raw.substr(0, headerEnd);
    std::string body = headerEnd == std::string::npos ? "" : raw.substr(headerEnd);

    std::istringstream stream(headerText);
    std::string requestLine;
    std::getline(stream, requestLine);
    requestLine = trimString(requestLine);

    std::string method;
    std::string target;
    std::string version;
    std::istringstream requestLineStream(requestLine);
    requestLineStream >> method >> target >> version;

    std::string path = target;
    std::string query = "";
    size_t queryStart = target.find('?');
    if (queryStart != std::string::npos) {
        path = target.substr(0, queryStart);
        query = target.substr(queryStart + 1);
    }

    std::map<std::string, std::string> headers;
    std::string line;
    while (std::getline(stream, line)) {
        line = trimString(line);
        if (line.empty()) {
            continue;
        }
        size_t colon = line.find(':');
        if (colon == std::string::npos) {
            continue;
        }
        headers[lowerString(trimString(line.substr(0, colon)))] = trimString(line.substr(colon + 1));
    }

    std::map<std::string, Value*> request;
    request["method"] = stringValue(method, location);
    request["path"] = stringValue(path, location);
    request["query"] = stringValue(query, location);
    request["body"] = stringValue(body, location);
    request["headers"] = dictValue(headersToTeaDict(headers, location), location);
    return dictValue(request, location);
}

static int openServerSocket(int port) {
    int serverFd = socket(AF_INET, SOCK_STREAM, 0);
    if (serverFd < 0) {
        return -1;
    }

    int opt = 1;
    setsockopt(serverFd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    struct sockaddr_in address;
    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);

    if (bind(serverFd, (struct sockaddr*)&address, sizeof(address)) < 0) {
        close(serverFd);
        return -1;
    }
    if (listen(serverFd, 16) < 0) {
        close(serverFd);
        return -1;
    }
    return serverFd;
}

struct HandlerRef {
    std::string name;
    AstNode *scope;
};

static HandlerRef getHandlerRef(Value *config, AstNode *fallbackScope, YYLTYPE location) {
    Value *handler = dictGet(config, "handler");
    if (handler == nullptr) {
        throw TypeError("serve() requires a handler", location);
    }

    if (handler->getTrueType() == FUNCTION) {
        return { handler->identValue, handler->scope };
    }

    if (handler->getTrueType() == STR) {
        std::string handlerName(handler->stringValue, handler->stringLength);
        if (handlerName.empty()) {
            throw TypeError("serve() requires a handler name", location);
        }
        return { handlerName, fallbackScope };
    }

    throw TypeError("serve() handler must be a function or string", location);
}

static Value* callHandler(HandlerRef handler, Value *request, YYLTYPE location) {
    AstNode *handlerScope = handler.scope;
    ExpressionNode *arg = new ExpressionNode(handlerScope);
    arg->value = copyValueDeep(request);

    FnCallNode call(copyString(handler.name), arg, handlerScope);
    call.setLocation(location);
    call.evaluate();
    return copyValueDeep(call.value);
}

static std::string buildServerResponse(Value *response, YYLTYPE location) {
    if (response->getTrueType() != DICT) {
        throw TypeError("HTTP server handler must return a dict", location);
    }

    int status = dictGetInt(response, "status", 200, location);
    std::string body = dictGetString(response, "body", "", location);
    std::map<std::string, std::string> headers = dictGetHeaders(response, location);

    std::ostringstream result;
    result << "HTTP/1.1 " << status << " OK\r\n";
    if (!hasHeader(headers, "Content-Length")) {
        result << "Content-Length: " << body.size() << "\r\n";
    }
    if (!hasHeader(headers, "Connection")) {
        result << "Connection: close\r\n";
    }
    for (auto const& item : headers) {
        result << item.first << ": " << item.second << "\r\n";
    }
    result << "\r\n" << body;
    return result.str();
}

ServeNode::ServeNode(AstNode *configExpression, AstNode *scope) : ExpressionNode(scope) {
    this->configExpression = configExpression;
    this->scope = scope;
}

AstNode* ServeNode::evaluate() {
    Value *config = evaluateExpression(this->configExpression, this->scope, this->location);
    if (config->getTrueType() != DICT) {
        throw TypeError("serve() expects a dict", this->location);
    }

    int port = dictGetInt(config, "port", 8080, this->location);
    HandlerRef handler = getHandlerRef(config, this->scope, this->location);

    int serverFd = openServerSocket(port);
    if (serverFd < 0) {
        this->value = makeHttpResponse(0, "", {}, "Could not listen on port " + std::to_string(port), this->location);
        return this->getNext();
    }

    while (true) {
        int clientFd = accept(serverFd, nullptr, nullptr);
        if (clientFd < 0) {
            continue;
        }

        std::string rawRequest = readHttpRequest(clientFd);
        Value *request = parseServerRequest(rawRequest, this->location);
        Value *response = callHandler(handler, request, this->location);
        std::string rawResponse = buildServerResponse(response, this->location);
        send(clientFd, rawResponse.c_str(), rawResponse.size(), 0);
        close(clientFd);
    }

    close(serverFd);
    this->value = makeHttpResponse(0, "", {}, "Server stopped", this->location);
    return this->getNext();
}
