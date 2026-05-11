#!../tea
import "lib/renderer.t";
import "@common/iterable.t";
str version = env("BUILD_NO");

if (len(version) == 0) {
    version = "dev";
};

str buildDate = replace(cmd("date '+%Y-%m-%d %H:%M:%S'"), "\n", "");
if (len(buildDate) == 0) {
    buildDate = "unknown";
};

str uploadDirectory = env("TEA_UPLOAD_DIR");
if (len(uploadDirectory) == 0) {
  uploadDirectory = "/tmp/tea-upload";
};

str fn joinPath(str directory, str fileName) {
  if (directory[len(directory) - 1] == "/") {
    return directory + fileName;
  };
  return directory + "/" + fileName;
};

bool fn hasFile(str directory, str fileName) {
  str listCommand = "ls " + directory;
  array files = split(cmd(listCommand), "\n");
  for (int i = 0; i < len(files); i = i + 1) {
    if (files[i] == fileName) {
      return true;
    };
  };
  return false;
};

bool fn isEmptyString(str string) {
  return len(string) == 0;
};

bool fn isValidStaticFile(str path) {
  str fileName = replace(path, "/static/", "");
  return hasFile("templates/static/", fileName);
};

bool fn isValidUploadFile(str fileName) {
  return hasFile(uploadDirectory, fileName);
};

str fn getMimeType(str path) {
  str extension = split(path, ".")[1];
  if (extension == "css") {
    return "text/css; charset=utf-8";
  };
  if (extension == "js") {
    return "application/javascript; charset=utf-8";
  };
  if (extension == "html") {
    return "text/html; charset=utf-8";
  };
  if (extension == "bin") {
    return "application/octet-stream";
  };
  return "text/plain; charset=utf-8";
};

str fn getTemplatePath(str path) {
  if (path == "/") {
    return "templates/index.t.html";
  };
  array files = split(cmd("ls templates/"), "\n");
  array requestedFileNamePathParts = split(replace(path, "/", ""), ".");
  if(len(requestedFileNamePathParts) != 2) {
    return "";
  };
  str requestedTemplateName = requestedFileNamePathParts[0] + ".t." + requestedFileNamePathParts[1];
  for (int i = 0; i < len(files); i = i + 1) {
    if (files[i] == requestedTemplateName) {
      return "templates/" + files[i];
    };
  };
  return "";
};

dict fn app(dict req) {
  dict fn getHeaders(str contentType) {
    return {"Content-Type": contentType, "Server": "Tea 2", "x-tea-version": version, "x-tea-build-date": buildDate};
  };

  str path = req["path"];
  if (isValidStaticFile(path)) {
    str filePath = "templates" + path;
    return {
      status: 200,
      headers: getHeaders(getMimeType(path)),
      body: read(filePath)
    };
  };
  if (path == "/upload" and req["method"] == "POST") {
    if (not hasItem("body", req) or not hasItem("headers", req)) {
      return {
        status: 400,
        headers: getHeaders("text/plain"),
        body: "Bad Request"
      };
    };

    str body = req["body"];
    dict headers = req["headers"];
    if (body == "" or not hasItem("content-type", headers)) {
      return {
        status: 400,
        headers: getHeaders("text/plain"),
        body: "Bad Request"
      };
    };

    if (not hasItem("authorization", headers)) {
      return {
        status: 401,
        headers: getHeaders("text/plain"),
        body: "Unauthorized"
      };
    };

    str authHeader = headers["authorization"];
    array authHeaderParts = split(authHeader, " ");
    if (len(authHeaderParts) != 2) {
      return {
        status: 401,
        headers: getHeaders("text/plain"),
        body: "Unauthorized"
      };
    };
    str authToken = authHeaderParts[1];
    if (authHeader == "" or authToken != env("TEA_API_TOKEN")) {
      return {
        status: 401,
        headers: getHeaders("text/plain"),
        body: "Unauthorized"
      };
    };
    array contentTypeParts = split(headers["content-type"], "boundary=");
    if (len(contentTypeParts) != 2) {
      return {
        status: 400,
        headers: getHeaders("text/plain"),
        body: "Bad Request"
      };
    };
    str boundary = contentTypeParts[1];
    str marker = "--" + boundary;
    str part = split(body, marker)[1];
      str headerSeparator = "\r\n\r\n";
    if (len(find(part, headerSeparator)) == 0) {
      headerSeparator = "\n\n";
    };
      str fileHeaders = split(part, headerSeparator)[0];
    str fileName = split(split(fileHeaders, "filename=\"")[1], "\"")[0];
    array fileNameParts = regexCapture(fileName, "^(.+)-(\\d+\\.\\d+\\.\\d+)(\\.t)$");
    if (len(fileNameParts) != 3) {
      return {
        status: 400,
        headers: getHeaders("text/plain"),
        body: "Bad Request"
      };
    };
    int contentStart = find(part, headerSeparator)[0] + len(headerSeparator);
    str fileContent = getSubstring(part, contentStart, len(part));
    if (len(fileContent) > 1 and fileContent[len(fileContent) - 2] == "\r" and fileContent[len(fileContent) - 1] == "\n") {
      fileContent = getSubstring(fileContent, 0, len(fileContent) - 2);
    };
    if (len(fileContent) > 0 and fileContent[len(fileContent) - 1] == "\n") {
      fileContent = getSubstring(fileContent, 0, len(fileContent) - 1);
    };
    str mkdirCommand = "mkdir -p " + uploadDirectory;
    cmd(mkdirCommand);
    str command = "ls " + uploadDirectory;
    str uploadDirectoryContent = cmd(command);
    array filesInUploadDirectory = split(uploadDirectoryContent, "\n");
    for (int i = 0; i < len(filesInUploadDirectory); i = i + 1) {
      if (filesInUploadDirectory[i] == fileName) {
        return {
          status: 409,
          headers: getHeaders("text/plain"),
          body: "File already exists"
        };
      };
    };
    write(joinPath(uploadDirectory, fileName), fileContent);
    return {
      status: 200,
      headers: getHeaders("text/plain"),
      body: "I got your file: " + fileName + " with content: " + fileContent
    };
  };

  if (path == "/download") {
    str fileName = split(req["query"], "file=")[1];
    str amendedFileName = replace(fileName, "%20", " ");
    str filePath = joinPath(uploadDirectory, amendedFileName);
    if (not isValidUploadFile(amendedFileName)) {
      return {
        status: 404,
        headers: getHeaders("text/plain"),
        body: "file not found"
      };
    };
    str fileContent = read(filePath);
    dict headers = getHeaders("application/octet-stream");
    headers["Content-Disposition"] = "attachment; filename=\"" + fileName + "\"; filename*=UTF-8''" + fileName;
    return {
      status: 200,
      headers: headers,
      body: fileContent
    };
  };

  str templatePath = getTemplatePath(path);
  if (len(templatePath) > 0) {
    str result = renderTemplate(read(templatePath), {version: version, build_date: buildDate});
    if (templatePath == "templates/downloads.t.html") {
      str listCommand = "ls " + uploadDirectory;
      array files = filter(split(cmd(listCommand), "\n"), not isEmptyString);
      str filesResult = "<ul>";
      for (int i = 0; i < len(files); i = i + 1) {
        filesResult = filesResult + "<li><a href=\"/download?file=" + files[i] + "\">" + files[i] + "</a></li>";
      };
      filesResult = filesResult + "</ul>";
      result = renderTemplate(read(templatePath), {version: version, build_date: buildDate, files: filesResult});
    };
    return {
      status: 200,
      headers: getHeaders("text/html"),
      body: result
    };
  };

  return {
    status: 404,
    headers: getHeaders("text/plain"),
    body: "not found"
  };
};

int port;
if (len(SYSARGS) < 3) {
  port = 5000;
} else {
  str portString = SYSARGS[2];
  port = cast(portString, int);
};

print("Server running on port http://localhost:", port);

dict server = serve({port: port, handler: app});

if (server["error"]) {
  print("Error: ", server["error"]);
  quit(98);
};
