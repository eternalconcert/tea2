#!../tea
import "lib/renderer.t";
str version = replace(cmd("echo $BUILDER_RUN"), "\n", "");
if (len(version) == 0) {
    version = "dev";
};

str buildDate = replace(cmd("date '+%Y-%m-%d %H:%M:%S'"), "\n", "");
if (len(buildDate) == 0) {
    buildDate = "unknown";
};

bool fn isValidStaticFile(str path) {
  array files = split(cmd("ls templates/static/"), "\n");
  for (int i = 0; i < len(files); i = i + 1) {
    if ("/static/" + files[i] == path) {
      return true;
    };
  };
  return false;
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
  return "text/plain; charset=utf-8";
};

str fn getTemplatePath(str path) {
  if (path == "/") {
    return "templates/index.t.html";
  };
  array files = split(cmd("ls templates/"), "\n");
  array requestedFileNamePathParts = split(replace(path, "/", ""), ".");
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

  str templatePath = getTemplatePath(path);
  if (len(templatePath) > 0) {
    str result = renderTemplate(read(templatePath), {version: version, build_date: buildDate});
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

print("Server running on port ", port);
serve({port: port, handler: app});
