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

export bool fn hasItem(str key, dict dictionary) {
  return arrayContains(dictKeys(dictionary), key);
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

export array fn range(int inValue) {
  array result = [];
  for (int i = 0; i < inValue; i = i + 1) {
    result[i] = i;
  };
  return result;
};

export array fn enumerate(array inArray) {
  array result = [];
  for (int i = 0; i < len(inArray); i = i + 1) {
    result[i] = [i, inArray[i]];
  };
  return result;
};

export array fn enumerateString(str inString) {
  array result = [];
  for (int i = 0; i < len(inString); i = i + 1) {
    result[i] = [i, inString[i]];
  };
  return result;
};
