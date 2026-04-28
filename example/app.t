#!../tea
import "../common/string.t";
import "lib/renderer.t";

array templates = ["templates/index.t.html", "templates/about.t.html"];
array titles = ["The Tea Programming Language", "About"];

for (int i = 0; i < len(templates); i = i + 1) {
    print(i + 1 + "/" + len(templates) + ": rendering template " + templates[i]);
    str template = templates[i];
    str result = render(template, ["title:" + titles[i]], ["templates/header.t.html", "templates/footer.t.html"]);
    array fileNameSplitted = split(template, "/");
    str fileName = replace(fileNameSplitted[1], ".t.html", ".html");
    write("build/" + fileName, result);
};

write("build/static/main.css", read("templates/static/main.css"));
