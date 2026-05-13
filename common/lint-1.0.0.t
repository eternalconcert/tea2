void fn usage() {
  print("usage: tea lint.t <file.t> [file.t ...]");
};

bool fn isSpace(str c) {
  return c == " " || c == "\t" || c == "\r";
};

bool fn isIdentStart(str c) {
  return len(find("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_", c)) > 0;
};

bool fn isIdentPart(str c) {
  return len(find("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789", c)) > 0;
};

bool fn isTypeWord(str word) {
  return word == "int" || word == "float" || word == "str" || word == "bool" || word == "array" || word == "dict" || word == "fn";
};

bool fn isUnescapedQuote(str line, int index) {
  if (line[index] != "\"") {
    return false;
  };
  if (index == 0) {
    return true;
  };
  return line[index - 1] != "\\";
};

str fn wordAt(str line, int start) {
  str result = "";
  int i = start;
  while (i < len(line) && isIdentPart(line[i])) {
    result = result + line[i];
    i = i + 1;
  };
  return result;
};

int fn nextWordStart(str line, int start) {
  int i = start;
  while (i < len(line) && isSpace(line[i])) {
    i = i + 1;
  };
  return i;
};

str fn stripStringsAndComments(str line) {
  str result = "";
  bool inString = false;
  int i = 0;
  while (i < len(line)) {
    str c = line[i];
    if (inString == false && c == "/" && i + 1 < len(line) && line[i + 1] == "/") {
      return result;
    };
    if (isUnescapedQuote(line, i)) {
      inString = inString == false;
      result = result + " ";
    } else {
      if (inString) {
        result = result + " ";
      } else {
        result = result + c;
      };
    };
    i = i + 1;
  };
  return result;
};

bool fn isBlank(str line) {
  int i = 0;
  while (i < len(line)) {
    if (isSpace(line[i]) == false) {
      return false;
    };
    i = i + 1;
  };
  return true;
};

int fn indentation(str line) {
  int i = 0;
  while (i < len(line) && line[i] == " ") {
    i = i + 1;
  };
  return i;
};

bool fn hasLeadingTab(str line) {
  int i = 0;
  while (i < len(line) && isSpace(line[i])) {
    if (line[i] == "\t") {
      return true;
    };
    i = i + 1;
  };
  return false;
};

bool fn endsStatement(str line) {
  int i = len(line) - 1;
  while (i >= 0 && isSpace(line[i])) {
    i = i - 1;
  };
  if (i < 0) {
    return false;
  };
  return line[i] == ";";
};

bool fn startsWithClosingBrace(str line) {
  int i = nextWordStart(line, 0);
  if (i >= len(line)) {
    return false;
  };
  return line[i] == "}";
};

int fn blockIndentDelta(str line) {
  int result = 0;
  int i = 0;
  while (i < len(line)) {
    if (line[i] == "{") {
      result = result + 2;
    };
    if (line[i] == "}") {
      result = result - 2;
    };
    i = i + 1;
  };
  return result;
};

str fn declarationName(str line) {
  int firstStart = nextWordStart(line, 0);
  str first = wordAt(line, firstStart);
  if (isTypeWord(first) == false) {
    return "";
  };

  int secondStart = nextWordStart(line, firstStart + len(first));
  str second = wordAt(line, secondStart);
  if (second == "" || second == "fn") {
    return "";
  };
  return second;
};

int fn warn(str fileName, int lineNumber, str rule, str message) {
  print(fileName + ":" + lineNumber + ":1: warning[" + rule + "]: " + message);
  return 1;
};

int fn lintFile(str fileName) {
  array lines = split(read(fileName), "\n");
  array strippedLines = [];
  array declarationNames = [];
  array declarationLines = [];
  dict declarationUses = {};
  str declarationLookup = "|";
  int warnings = 0;
  int blankLinesAfterStatement = 0;
  bool previousWasStatement = false;
  int expectedIndent = 0;

  for (int i = 0; i < len(lines); i = i + 1) {
    str rawLine = lines[i];
    str line = stripStringsAndComments(rawLine);
    strippedLines[len(strippedLines)] = line;
    int lineNumber = i + 1;
    int currentExpectedIndent = expectedIndent;

    if (startsWithClosingBrace(line)) {
      currentExpectedIndent = currentExpectedIndent - 2;
      if (currentExpectedIndent < 0) {
        currentExpectedIndent = 0;
      };
    };

    if (isBlank(rawLine) == false) {
      if (hasLeadingTab(rawLine) || indentation(rawLine) % 2 != 0) {
        warnings = warnings + warn(fileName, lineNumber, "indent", "indentation must use spaces in multiples of 2");
      } else {
        if (isBlank(line) == false && indentation(rawLine) != currentExpectedIndent) {
          warnings = warnings + warn(fileName, lineNumber, "indent", "indentation must match the current block depth");
        };
      };
    };

    if (isBlank(line) && isBlank(rawLine) == false) {
      previousWasStatement = false;
      blankLinesAfterStatement = 0;
    } else {
      if (isBlank(line)) {
        if (previousWasStatement) {
          blankLinesAfterStatement = blankLinesAfterStatement + 1;
          if (blankLinesAfterStatement > 1) {
            warnings = warnings + warn(fileName, lineNumber, "blank-lines", "more than one blank line after a statement");
          };
        };
      } else {
        previousWasStatement = endsStatement(line);
        blankLinesAfterStatement = 0;
      };
    };

    str declared = declarationName(line);
    if (declared != "") {
      declarationNames[len(declarationNames)] = declared;
      declarationLines[len(declarationLines)] = lineNumber;
      declarationUses[declared] = 0;
      declarationLookup = declarationLookup + declared + "|";
    };

    if (isBlank(line) == false) {
      expectedIndent = expectedIndent + blockIndentDelta(line);
      if (expectedIndent < 0) {
        expectedIndent = 0;
      };
    };
  };

  for (int i = 0; i < len(strippedLines); i = i + 1) {
    str line = strippedLines[i];
    int pos = 0;
    while (pos < len(line)) {
      if (isIdentStart(line[pos])) {
        str word = wordAt(line, pos);
        if (len(find(declarationLookup, "|" + word + "|")) > 0) {
          declarationUses[word] = declarationUses[word] + 1;
        };
        pos = pos + len(word);
      } else {
        pos = pos + 1;
      };
    };
  };

  for (int d = 0; d < len(declarationNames); d = d + 1) {
    if (declarationUses[declarationNames[d]] <= 1) {
      warnings = warnings + warn(fileName, declarationLines[d], "unused-variable", "variable '" + declarationNames[d] + "' is never used");
    };
  };

  return warnings;
};

if (len(SYSARGS) < 3) {
  usage();
  quit(1);
};

int warnings = 0;
for (int i = 2; i < len(SYSARGS); i = i + 1) {
  warnings = warnings + lintFile(SYSARGS[i]);
};

if (warnings > 0) {
  quit(1);
};
