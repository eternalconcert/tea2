import "@common/string.t";
import "@common/iterable.t";

export str fn render(str template, dict context, array includes) {
    str templateContent = read(template);

    // First replace include placeholders like %templates/header.t.html%
    for (int i = 0; i < len(includes); i = i + 1) {
        str incl = includes[i];
        str inclContent = read(incl);
        templateContent = replace(templateContent, "%" + incl + "%", inclContent);
    };

    array contextItems = dictItems(context);
    for (int i = 0; i < len(contextItems); i = i + 1) {
        array item = contextItems[i];
        str key = item[0];
        str value = item[1];
        templateContent = replace(templateContent, "%" + key + "%", value);
    };
    return templateContent;
};
