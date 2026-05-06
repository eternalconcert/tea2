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

array files = split(cmd("ls templates"), "\n");
array templates = [];
for (int i = 0; i < len(files); i = i + 1) {
    bool validTemplate = len(find(files[i], ".t.html")) > 0;
    if (files[i] != "_base.t.html" and validTemplate) {
        templates[len(templates)] = "templates/" + files[i];
    };
};

for (int i = 0; i < len(templates); i = i + 1) {
    print(i + 1 + "/" + len(templates) + ": rendering template " + templates[i]);
    str template = templates[i];
    str result = renderTemplate(read(template), {version: version, build_date: buildDate});
    array fileNameSplitted = split(template, "/");
    str fileName = replace(fileNameSplitted[1], ".t.html", ".html");
    write("build/" + fileName, result);
};

write("build/static/main.css", read("templates/static/main.css"));
