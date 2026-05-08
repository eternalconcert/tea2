export array fn dictItems(dict dictionaies) {
  array keys = dictKeys(dictionaies);
  array values = dictValues(dictionaies);
  array items = [];
  for (int i = 0; i < len(keys); i = i + 1) {
    items[i] = [keys[i], values[i]];
  };
  return items;
};

export array fn arrayContains(array arrayToCheck, str item) {
  for (int i = 0; i < len(arrayToCheck); i = i + 1) {
    if (arrayToCheck[i] == item) {
      return true;
    };
  };
  return false;
};

export array fn filter(array arrayToFilter, fn predicate) {
  array result = [];
  for (int i = 0; i < len(arrayToFilter); i = i + 1) {
    if (predicate(arrayToFilter[i])) {
      result[len(result)] = arrayToFilter[i];
    };
  };
  return result;
};
