export str fn getSubstring(str invalue, int startIndex, int endIndex) {
  str result = "";
  int i = startIndex;
  while (i < endIndex) {
    result = result + invalue[i];
    i = i + 1;
  };
  return result;
};


export str fn replace(str invalue, str pattern, str replacement) {
    array startIndexes = find(invalue, pattern);
    int numberOfMatches = len(startIndexes);
    int i = 0;
    int offset = 0;
    while (i < numberOfMatches) {
      int startIndex = startIndexes[i] + offset;
      int endIndex = startIndex + len(pattern);
      str before = getSubstring(invalue, 0, startIndex);
      str after = getSubstring(invalue, endIndex, len(invalue));
      invalue = before + replacement + after;
      offset = offset + len(replacement) - len(pattern);
      i = i + 1;
    };
    return invalue;
};


export str fn replaceMany(str invalue, array patterns, array replacements) {
    int numberOfPatterns = len(patterns);
    int numberOfReplacements = len(replacements);

    assert(
      numberOfPatterns,
      numberOfReplacements,
      replace(
        replace("Number of patterns (%numberOfPatterns%) and replacements (%numberOfReplacements%) must be the same", "%numberOfPatterns%", "" + numberOfPatterns),
        "%numberOfReplacements%", "" + numberOfReplacements
      )
    );

    int i = 0;
    while (i < numberOfPatterns) {
      invalue = replace(invalue, patterns[i], replacements[i]);
      i = i + 1;
    };
    return invalue;
};
