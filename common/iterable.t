export array fn dictItems(dict dictionaies) {
  array keys = dictKeys(dictionaies);
  array values = dictValues(dictionaies);
  array items = [];
  for (int i = 0; i < len(keys); i = i + 1) {
    items[i] = [keys[i], values[i]];
  };
  return items;
};
