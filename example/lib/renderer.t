import "../../common/string.t";


export str fn render(str template, array values, array includes) {
    str templateContent = read(template);
    for (int i = 0; i < len(includes); i = i + 1) {
        str incl = includes[i];
        str inclContent = read(incl);
        templateContent = replace(templateContent, "%" + includes[i] + "%", inclContent);
        };

    for (int i = 0; i < len(values); i = i + 1) {
        str value = values[i];
        array keyValue = split(value, ":");
        templateContent = replace(templateContent, "%" + keyValue[0] + "%", keyValue[1]);
    };
    return templateContent;
};
