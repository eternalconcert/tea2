import "@common/iterable.t";

export str fn addContext(str templateContent, dict context) {
    array contextItems = dictItems(context);
    for (int i = 0; i < len(contextItems); i = i + 1) {
        array item = contextItems[i];
        str key = item[0];
        str value = item[1];
        templateContent = replace(templateContent, "{%" + key + "%}", value);
    };
    return templateContent;
};

array fn getBaseTemplateNames(str template) {
  array result = [];
  array startIndexes = find(template, "%extends ");
  for (int i = 0; i < len(startIndexes); i = i + 1) {
    int baseTemplateNameStart = startIndexes[i] + len("%extends ");
    str substring = getSubstring(template, baseTemplateNameStart, len(template));
    int baseTemplateNameEnd = find(substring, "%")[0];
    str baseTemplateName = getSubstring(substring, 0, baseTemplateNameEnd);
    result[i] = baseTemplateName;
  };
  return result;
};

dict fn getBlocks(str template) {
  dict result = {};
  array startIndexes = find(template, "{%block ");
  for (int i = 0; i < len(startIndexes); i = i + 1) {
    int blockNameStart = startIndexes[i] + len("{%block ");
    str substring = getSubstring(template, blockNameStart, len(template));
    int blockNameEnd = find(substring, "%}")[0];
    str blockName = getSubstring(substring, 0, blockNameEnd);

    int blockContentEnd = find(substring, "{%endblock%}")[0];
    str blockContent = getSubstring(substring, blockNameEnd + 2, blockContentEnd);
    result[blockName] = blockContent;
  };
  return result;
};

export str fn renderTemplate(str template, dict context) {
  array baseTemplateNames = getBaseTemplateNames(template);
  if (len(baseTemplateNames) > 1) {
    throw TooManyExtendsError("Multiple extends found");
  } else {
    str baseTemplateName = baseTemplateNames[0];
    str baseTemplateContent = read(baseTemplateName);
    dict blocks = getBlocks(template);

    array blockNames = dictKeys(blocks);
    for (int i = 0; i < len(blocks); i = i + 1) {
      str blockName = blockNames[i];
      str blockContent = blocks[blockName];
      baseTemplateContent = replace(baseTemplateContent, "{%block " + blockName + "%}", blockContent);
    };
    return addContext(baseTemplateContent, context);
  };
};
