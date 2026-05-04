#!../tea
import "lib/renderer.t";

str version = replace(cmd("echo $BUILDER_RUN"), "\n", "");
if (len(version) == 0) {
    version = "dev";
};

str buildDate = replace(cmd("date '+%Y-%m-%d %H.%M.%S'"), "\n", "");
if (len(buildDate) == 0) {
    buildDate = "unknown";
};

array templates = ["templates/index.t.html", "templates/about.t.html", "templates/imprint.t.html", "templates/api.t.html"];
array titles = ["The Tea Programming Language", "About", "Imprint", "API"];

for (int i = 0; i < len(templates); i = i + 1) {
    print(i + 1 + "/" + len(templates) + ": rendering template " + templates[i]);
    str template = templates[i];
    str result = render(template, {title: titles[i], version: version, build_date: buildDate}, ["templates/header.t.html", "templates/footer.t.html"]);
    array fileNameSplitted = split(template, "/");
    str fileName = replace(fileNameSplitted[1], ".t.html", ".html");
    write("build/" + fileName, result);
};

write("build/static/main.css", read("templates/static/main.css"));
