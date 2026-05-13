import "@iterable.t";

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
  for (item in enumerate(regexCaptureAll(template, "\\{%\\s*extends\\s+([^%]+)\\s*%\\}"))) {
    int idx = item[0];
    result[idx] = item[1][0];
  };
  return result;
};

dict fn getBlocks(str template) {
  str blockPattern = "\\{%\\s*block\\s+(\\w+)\\s*%\\}";
  str endBlockPattern = "\\{%\\s*endblock\\s*%\\}";
  array blockStarts = regexFind(template, blockPattern);
  array blockNames = regexCaptureAll(template, blockPattern);
  array blockEnds = regexFind(template, endBlockPattern);
  dict result = {};
  for (int i = 0; i < len(blockStarts); i = i + 1) {
    int blockStart = blockStarts[i];
    str blockName = blockNames[i][0];
    str fromBlockStart = getSubstring(template, blockStart, len(template));
    int openingTagEnd = find(fromBlockStart, "%}")[0] + len("%}");
    int contentStart = blockStart + openingTagEnd;
    int contentEnd = blockEnds[i];
    result[blockName] = getSubstring(template, contentStart, contentEnd);
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
