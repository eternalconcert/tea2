#include <string.h>
#include <iostream>
#include <fstream>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"
#include "../utils/utils.h"
#include "unistd.h"

static char* copyString(const std::string &value) {
    char *copy = new char[value.size() + 1];
    strcpy(copy, value.c_str());
    return copy;
}


PrintNode::PrintNode(AstNode *paramsHead, AstNode *scope, bool newLine) {
    this->scope = scope;
    this->newLine = newLine;
    this->paramsHead = paramsHead;
    AstNode();
}

AstNode* PrintNode::evaluate() {
    AstNode *cur = this->paramsHead;

    cur->location = this->location; // Maybe this can help with the other problems. If removed, location will not work on printing identifiers.

    while (cur != NULL) {
        ExpressionNode *eval = (ExpressionNode*)cur;
        eval->evaluate();
        if (eval->value->type != UNDEFINED) {
            eval->value->repr();
        }
        cur = cur->getNext();
    }
    if (this->newLine) {
        printf("\n");
    };
    fflush(stdout);
    return this->getNext();
};


SystemArgsNode::SystemArgsNode(Value *indexValue, AstNode *scope) {
    this->scope = scope;
    this->indexValue = indexValue;
    AstNode();
}


AstNode* SystemArgsNode::evaluate() {
    int idx;
    switch (this->indexValue->type) {
        case INT:
            idx = this->indexValue->intValue;
            break;
        case IDENTIFIER: {
            Value *val = getFromValueStore(this->scope, this->indexValue->identValue, this->location);
            if (val->getTrueType() != INT) {
                throw (TypeError("Wrong type for index", this->location));
            }
            idx = val->intValue;
            break;
        }
        default:
            throw TypeError("Unsupported type for system args index", this->location);
    }
    System *sys = System::getSystem();
    if (sys->argc <= this->indexValue->intValue) {
        throw SystemError("Too less system args");
    } else {
        this->value->set(sys->args[idx], this->location);
    }
    return this->getNext();
};


LastRcNode::LastRcNode() {
    AstNode();
}


AstNode* LastRcNode::evaluate() {
    System *sys = System::getSystem();
    this->value->set(sys->lastRc, this->location);
    return this->getNext();
};

SleepNode::SleepNode(Value *seconds, AstNode *scope) {
    this->seconds = seconds;
    this->scope = scope;
    AstNode();
};


AstNode* SleepNode::evaluate() {
    switch (this->seconds->type) {
        case FLOAT:
            usleep(this->seconds->floatValue * 1000000);
            break;
        case INT:
            usleep(this->seconds->intValue * 1000000);
            break;
        case IDENTIFIER:
            Value *val = getFromValueStore(this->scope, this->seconds->identValue, this->location);
            if (val->getTrueType() == FLOAT) {
                usleep(val->floatValue * 1000000);
            }  else if (val->getTrueType() == INT) {
                usleep(val->intValue * 1000000);
            } else {
                throw (TypeError("Wrong type for sleep function", this->location));
            }
            break;
    }
    return this->getNext();
};

QuitNode::QuitNode(Value *rcValue, AstNode *scope) {
    this->rcValue = rcValue;
    this->scope = scope;
    AstNode();
};


AstNode* QuitNode::evaluate() {
    int rc;
    switch (this->rcValue->type) {
        case INT:
            rc = this->rcValue->intValue;
            break;
        case IDENTIFIER:
            Value *val = getFromValueStore(this->scope, this->rcValue->identValue, this->location);
            if (val->getTrueType() != INT) {
                throw (TypeError("Wrong type for exit function", this->location));
            }
            rc = val->intValue;
            break;
    }
    exit(rc);
    return this->getNext();
};

ReadFileNode::ReadFileNode(Value *pathValue, AstNode *scope) {
    this->pathValue = pathValue;
    this->scope = scope;
    AstNode();
};

std::string ReadFileNode::readFile(std::string path) {
    std::ifstream file(path);

    if (!file) {
        throw FileNotFoundException(path, this->location);
    }

    try {
        std::string content((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
        return content;
    } catch (std::ios_base::failure) {
        throw FileNotFoundException(path, this->location);
    }
};

AstNode* ReadFileNode::evaluate() {
    std::string fromFile;
    switch (this->pathValue->type) {
        case STR:
            fromFile = this->readFile(this->pathValue->stringValue);
            break;
        case IDENTIFIER: {
            Value *val = getFromValueStore(this->scope, this->pathValue->identValue, this->location);
            if (val->getTrueType() != STR) {
                throw (TypeError("Wrong type for read function", this->location));
            }
            fromFile = this->readFile(val->stringValue);
            break;
        }
        default:
            throw TypeError("Unsupported type for read function", this->location);
    }
    char* cStr = copyString(fromFile);
    this->value->set(cStr, this->location);
    return this->getNext();
};


WriteFileNode::WriteFileNode(AstNode *pathExpression, AstNode *contentExpression, AstNode *scope) {
    this->pathExpression = pathExpression;
    this->contentExpression = contentExpression;
    this->scope = scope;
    AstNode();
};

AstNode* WriteFileNode::evaluate() {
    ExpressionNode *pathEval = (ExpressionNode*)this->pathExpression;
    ExpressionNode *contentEval = (ExpressionNode*)this->contentExpression;

    pathEval->evaluate();
    contentEval->evaluate();

    if (pathEval->value->getTrueType() != STR) {
        throw TypeError("Wrong type for write path", this->location);
    }

    if (contentEval->value->getTrueType() != STR) {
        throw TypeError("Wrong type for write content", this->location);
    }

    std::ofstream file(pathEval->value->stringValue);
    if (!file) {
        throw SystemError("Could not open file for writing");
    }

    file << contentEval->value->stringValue;
    file.close();
    return this->getNext();
};

SplitNode::SplitNode(AstNode *stringExpression, AstNode *separatorExpression, AstNode *scope) {
    this->stringExpression = stringExpression;
    this->separatorExpression = separatorExpression;
    this->scope = scope;
    AstNode();
};

AstNode* SplitNode::evaluate() {
    ExpressionNode *stringEval = (ExpressionNode*)this->stringExpression;
    ExpressionNode *separatorEval = (ExpressionNode*)this->separatorExpression;

    stringEval->evaluate();
    separatorEval->evaluate();

    if (stringEval->value->getTrueType() != STR) {
        throw TypeError("Wrong type for split string", this->location);
    }

    if (separatorEval->value->getTrueType() != STR) {
        throw TypeError("Wrong type for split separator", this->location);
    }

    std::string input = stringEval->value->stringValue;
    std::string separator = separatorEval->value->stringValue;
    if (separator.empty()) {
        throw TypeError("Split separator cannot be empty", this->location);
    }

    std::vector<Value*> parts;
    size_t start = 0;
    size_t end = input.find(separator);

    while (end != std::string::npos) {
        Value *part = new Value();
        part->set(copyString(input.substr(start, end - start)), this->location);
        parts.push_back(part);
        start = end + separator.size();
        end = input.find(separator, start);
    }

    Value *part = new Value();
    part->set(copyString(input.substr(start)), this->location);
    parts.push_back(part);

    this->value->set(parts, this->location);
    return this->getNext();
};

FindNode::FindNode(AstNode *stringExpression, AstNode *patternExpression, AstNode *scope) {
    this->stringExpression = stringExpression;
    this->patternExpression = patternExpression;
    this->scope = scope;
    AstNode();
};

AstNode* FindNode::evaluate() {
    ExpressionNode *stringEval = (ExpressionNode*)this->stringExpression;
    ExpressionNode *patternEval = (ExpressionNode*)this->patternExpression;

    stringEval->evaluate();
    patternEval->evaluate();

    if (stringEval->value->getTrueType() != STR) {
        throw TypeError("Wrong type for find string", this->location);
    }

    if (patternEval->value->getTrueType() != STR) {
        throw TypeError("Wrong type for find pattern", this->location);
    }

    std::string input = stringEval->value->stringValue;
    std::string pattern = patternEval->value->stringValue;
    if (pattern.empty()) {
        throw TypeError("Find pattern cannot be empty", this->location);
    }

    std::vector<Value*> matches;
    size_t start = 0;
    size_t found = input.find(pattern, start);

    while (found != std::string::npos) {
        Value *match = new Value();
        match->set((int)found, this->location);
        matches.push_back(match);
        start = found + 1;
        found = input.find(pattern, start);
    }

    this->value->set(matches, this->location);
    return this->getNext();
};

LenNode::LenNode(AstNode *stringExpression, AstNode *scope) : ExpressionNode(scope) {
    this->stringExpression = stringExpression;
    this->scope = scope;
};

AstNode* LenNode::evaluate() {
    ExpressionNode *stringEval = (ExpressionNode*)this->stringExpression;
    stringEval->evaluate();

    if (stringEval->value->getTrueType() == STR) {
        this->value->set((int)strlen(stringEval->value->stringValue), this->location);
        if (this->childListHead != NULL && this->childListHead != this) {
            this->initialValue = new Value(*this->value);
            return ExpressionNode::evaluate();
        }
        return this->getNext();
    }

    if (stringEval->value->getTrueType() == ARRAY) {
        this->value->set((int)stringEval->value->arrayValue.size(), this->location);
        if (this->childListHead != NULL && this->childListHead != this) {
            this->initialValue = new Value(*this->value);
            return ExpressionNode::evaluate();
        }
        return this->getNext();
    }

    if (stringEval->value->getTrueType() == DICT) {
        this->value->set((int)stringEval->value->dictValue.size(), this->location);
        if (this->childListHead != NULL && this->childListHead != this) {
            this->initialValue = new Value(*this->value);
            return ExpressionNode::evaluate();
        }
        return this->getNext();
    }

    throw TypeError("Wrong type for len", this->location);
};

KeysNode::KeysNode(AstNode *dictExpression, AstNode *scope) : ExpressionNode(scope) {
    this->dictExpression = dictExpression;
    this->scope = scope;
};

AstNode* KeysNode::evaluate() {
    ExpressionNode *dictEval = (ExpressionNode*)this->dictExpression;
    dictEval->evaluate();

    if (dictEval->value->getTrueType() != DICT) {
        throw TypeError("Wrong type for keys", this->location);
    }

    std::vector<Value*> keys;
    for (auto const& item : dictEval->value->dictValue) {
        Value *keyVal = new Value();
        keyVal->set(copyString(item.first), this->location);
        keys.push_back(keyVal);
    }

    this->value->set(keys, this->location);
    if (this->childListHead != NULL && this->childListHead != this) {
        this->initialValue = new Value(*this->value);
        return ExpressionNode::evaluate();
    }
    return this->getNext();
};

ValuesNode::ValuesNode(AstNode *dictExpression, AstNode *scope) : ExpressionNode(scope) {
    this->dictExpression = dictExpression;
    this->scope = scope;
};

AstNode* ValuesNode::evaluate() {
    ExpressionNode *dictEval = (ExpressionNode*)this->dictExpression;
    dictEval->evaluate();

    if (dictEval->value->getTrueType() != DICT) {
        throw TypeError("Wrong type for values", this->location);
    }

    std::vector<Value*> values;
    for (auto const& item : dictEval->value->dictValue) {
        values.push_back(new Value(*item.second));
    }

    this->value->set(values, this->location);
    if (this->childListHead != NULL && this->childListHead != this) {
        this->initialValue = new Value(*this->value);
        return ExpressionNode::evaluate();
    }
    return this->getNext();
};


InputNode::InputNode(AstNode *scope) {
    this->scope = scope;
    AstNode();
};

void InputNode::readInput() {};

AstNode* InputNode::evaluate() {
    std::string in;
    std::getline(std::cin, in);
    char* cStr = copyString(in);
    this->value->set(cStr, this->location);
    return this->getNext();
};

AssertNode::AssertNode(AstNode *paramsHead, AstNode *scope) {
    this->scope = scope;
    this->paramsHead = paramsHead;
    AstNode();
}

AstNode* AssertNode::evaluate() {
    AstNode *cur = this->paramsHead;
    std::vector<Value*> values;
    while (cur != NULL) {
        ExpressionNode *eval = (ExpressionNode*)cur;
        eval->evaluate();
        values.push_back(eval->value);
        cur = cur->getNext();
    }

    bool hasMessage = values.size() == 3 && values[2]->getTrueType() == STR;
    size_t compareCount = hasMessage ? 2 : values.size();
    std::string message = hasMessage ? values[2]->stringValue : "";

    for (size_t i = 1; i < compareCount; i++) {
        Value& lVal = *values[i];
        Value *rVal = values[i - 1];
        if (operator!=(lVal, rVal)->boolValue) {
            if (hasMessage) {
                throw AssertionError(rVal, values[i], message, this->location);
            }
            throw AssertionError(rVal, values[i], this->location);
        }
    }

    return this->getNext();
};



CastNode::CastNode(char* identifier, typeId typeName, AstNode* scope) {
    this->identifier = identifier;
    this->typeName = typeName;
    this->scope = scope;
    this->parent = scope;
}

AstNode* CastNode::evaluate() {
    Value* value = getFromValueStore(this->scope, this->identifier, this->location);
    switch (this->typeName) {
        case UNDEFINED:
            // Nichts zu tun oder Fehler werfen
            break;

        case INT: {
            value->toInt(this->location);
            break;
        }

        case FLOAT: {
            float num = std::stof(value->stringValue);
            value->set(num, this->location);
            break;
        }

        case STR: {
            value->toStr(this->location);
            break;
        }

        case BOOL: {
            bool b = (strcmp(value->stringValue, "true") == 0 || strcmp(value->stringValue, "1") == 0);
            value->set(b, this->location);
            break;
        }
    }
    return this->getNext();
}

CmdNode::CmdNode(Value *shValue, AstNode *scope) {
    this->shValue = shValue;
    this->scope = scope;
    AstNode();
};


AstNode* CmdNode::evaluate() {
    std::string result;
    switch (this->shValue->type) {
        case STR:
            result = exec(shValue->stringValue);
            break;
        case IDENTIFIER: {
            Value *val = getFromValueStore(this->scope, this->shValue->identValue, this->location);
            if (val->getTrueType() != STR) {
                throw (TypeError("Wrong type for cmd function", this->location));
            }
            result = exec(val->stringValue);
            break;
        }
        default:
            throw TypeError("Unsupported type for cmd function", this->location);
    }
    char* cStr = copyString(result);
    this->value->set(cStr, this->location);
    return this->getNext();
};
