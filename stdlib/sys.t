void fn print(...arguments) {
  for (int i = 0; i < len(arguments); i = i + 1) {
        sysprint(arguments[i]);
    };
    return sysprint("\n");
};

str fn _jc(str s, int i) {
    return s[i];
};

int fn _skip(str s, int i) {
    while (i < len(s)) {
        str c = _jc(s, i);
        if (c == " " || c == "\n" || c == "\t" || c == "\r") {
            i = i + 1;
        } else {
            break;
        };
    };
    return i;
};

dict fn _err(str m, int p) {
    throw JsonError(m + " at " + p);
    return {"i": p, "v": 0};
};

bool fn _isdigit(str c) {
    return len(find("0123456789", c)) > 0;
};

int fn _dig(str c) {
    if (c == "0") { return 0; };
    if (c == "1") { return 1; };
    if (c == "2") { return 2; };
    if (c == "3") { return 3; };
    if (c == "4") { return 4; };
    if (c == "5") { return 5; };
    if (c == "6") { return 6; };
    if (c == "7") { return 7; };
    if (c == "8") { return 8; };
    if (c == "9") { return 9; };
    throw JsonError("bad digit");
    return 0;
};

int fn _hex(str c) {
    if (_isdigit(c)) { return _dig(c); };
    if (c == "a" || c == "A") { return 10; };
    if (c == "b" || c == "B") { return 11; };
    if (c == "c" || c == "C") { return 12; };
    if (c == "d" || c == "D") { return 13; };
    if (c == "e" || c == "E") { return 14; };
    if (c == "f" || c == "F") { return 15; };
    throw JsonError("bad hex");
    return 0;
};

dict fn _parseString(str s, int i) {
    i = _skip(s, i);
    if (i >= len(s)) {
        return _err("expected string", i);
    };
    if (_jc(s, i) != "\"") {
        return _err("expected string", i);
    };
    i = i + 1;
    str out = "";
    while (i < len(s)) {
        str ch = _jc(s, i);
        if (ch == "\"") {
            i = i + 1;
            return {"i": i, "v": out};
        };
        if (ch == "\\") {
            i = i + 1;
            if (i >= len(s)) {
                return _err("bad escape", i);
            };
            str e = _jc(s, i);
            if (e == "\"") { out = out + "\""; i = i + 1; continue; };
            if (e == "\\") { out = out + "\\"; i = i + 1; continue; };
            if (e == "/") { out = out + "/"; i = i + 1; continue; };
            if (e == "n") { out = out + "\n"; i = i + 1; continue; };
            if (e == "t") { out = out + "\t"; i = i + 1; continue; };
            if (e == "r") { out = out + "\n"; i = i + 1; continue; };
            if (e == "b") { out = out + ""; i = i + 1; continue; };
            if (e == "f") { out = out + ""; i = i + 1; continue; };
            if (e == "u") {
                if (i + 4 >= len(s)) {
                    return _err("bad \\u", i);
                };
                _hex(_jc(s, i + 1));
                _hex(_jc(s, i + 2));
                _hex(_jc(s, i + 3));
                _hex(_jc(s, i + 4));
                out = out + "?";
                i = i + 5;
                continue;
            };
            return _err("bad escape", i);
        };
        out = out + ch;
        i = i + 1;
    };
    return _err("unterminated string", i);
};

dict fn _parseNumber(str s, int i) {
    i = _skip(s, i);
    int start = i;
    bool neg = false;
    if (i < len(s)) {
        if (_jc(s, i) == "-") {
            neg = true;
            i = i + 1;
        };
    };
    if (i >= len(s)) {
        return _err("expected number", start);
    };
    if (_isdigit(_jc(s, i)) == false) {
        return _err("expected number", start);
    };
    int ip = 0;
    while (i < len(s)) {
        if (_isdigit(_jc(s, i)) == false) {
            break;
        };
        ip = ip * 10 + _dig(_jc(s, i));
        i = i + 1;
    };
    bool isFloat = false;
    float frac = 0.0;
    float div = 1.0;
    if (i < len(s)) {
        if (_jc(s, i) == ".") {
            isFloat = true;
            i = i + 1;
            if (i >= len(s)) {
                return _err("bad fraction", i);
            };
            if (_isdigit(_jc(s, i)) == false) {
                return _err("bad fraction", i);
            };
            while (i < len(s)) {
                if (_isdigit(_jc(s, i)) == false) {
                    break;
                };
                frac = frac * 10.0 + _dig(_jc(s, i));
                div = div * 10.0;
                i = i + 1;
            };
        };
    };
    int expSign = 1;
    int expVal = 0;
    if (i < len(s)) {
        str ee = _jc(s, i);
        if (ee == "e" || ee == "E") {
            isFloat = true;
            i = i + 1;
            if (i < len(s)) {
                if (_jc(s, i) == "+") {
                    i = i + 1;
                };
            };
            if (i < len(s)) {
                if (_jc(s, i) == "-") {
                    expSign = -1;
                    i = i + 1;
                };
            };
            if (i >= len(s)) {
                return _err("bad exp", i);
            };
            if (_isdigit(_jc(s, i)) == false) {
                return _err("bad exp", i);
            };
            while (i < len(s)) {
                if (_isdigit(_jc(s, i)) == false) {
                    break;
                };
                expVal = expVal * 10 + _dig(_jc(s, i));
                i = i + 1;
            };
        };
    };
    if (isFloat == false) {
        int v = ip;
        if (neg) {
            v = 0 - ip;
        };
        return {"i": i, "v": v};
    };
    float v = ip + 0.0 + frac / div;
    if (neg) {
        v = 0.0 - v;
    };
    int e = expVal;
    while (e > 0) {
        if (expSign > 0) {
            v = v * 10.0;
        } else {
            v = v / 10.0;
        };
        e = e - 1;
    };
    return {"i": i, "v": v};
};

dict fn _lit(str s, int i, str word, dict box) {
    i = _skip(s, i);
    int k = 0;
    while (k < len(word)) {
        if (i + k >= len(s)) {
            return _err("expected " + word, i);
        };
        if (_jc(s, i + k) != _jc(word, k)) {
            return _err("expected " + word, i);
        };
        k = k + 1;
    };
    return {"i": i + len(word), "v": box["v"]};
};

dict fn _parseObjectAfterBrace(str s, int i) {
    dict acc = {};
    if (i < len(s)) {
        str ch = _jc(s, i);
        if (ch == "}") {
            return {"i": i + 1, "v": acc};
        };
    };
    bool done = false;
    while (done == false) {
        dict pk = _parseString(s, i);
        str key = pk["v"];
        i = _skip(s, pk["i"]);
        if (i >= len(s)) {
            return _err("expected :", i);
        };
        if (_jc(s, i) != ":") {
            return _err("expected :", i);
        };
        i = i + 1;
        dict pv = _parseValue(s, i);
        acc[key] = pv["v"];
        i = _skip(s, pv["i"]);
        if (i >= len(s)) {
            return _err("unclosed object", i);
        };
        str sep = _jc(s, i);
        if (sep == ",") {
            i = i + 1;
        } else {
            if (sep == "}") {
                i = i + 1;
                done = true;
            } else {
                return _err("expected , or }", i);
            };
        };
    };
    return {"i": i, "v": acc};
};

dict fn _parseArrayAfterBracket(str s, int i) {
    array a = [];
    if (i < len(s)) {
        if (_jc(s, i) == "]") {
            return {"i": i + 1, "v": a};
        };
    };
    bool done = false;
    while (done == false) {
        dict pv = _parseValue(s, i);
        a[len(a)] = pv["v"];
        i = _skip(s, pv["i"]);
        if (i >= len(s)) {
            return _err("unclosed array", i);
        };
        str sep = _jc(s, i);
        if (sep == ",") {
            i = i + 1;
        } else {
            if (sep == "]") {
                i = i + 1;
                done = true;
            } else {
                return _err("expected , or ]", i);
            };
        };
    };
    return {"i": i, "v": a};
};

dict fn _parseValue(str s, int i) {
    i = _skip(s, i);
    if (i >= len(s)) {
        return _err("unexpected end", i);
    };
    str c = _jc(s, i);
    if (c == "\"") {
        return _parseString(s, i);
    };
    if (c == "{") {
        i = i + 1;
        i = _skip(s, i);
        return _parseObjectAfterBrace(s, i);
    };
    if (c == "[") {
        i = i + 1;
        i = _skip(s, i);
        return _parseArrayAfterBracket(s, i);
    };
    if (c == "t") {
        return _lit(s, i, "true", {"v": true});
    };
    if (c == "f") {
        return _lit(s, i, "false", {"v": false});
    };
    if (c == "n") {
        return _lit(s, i, "null", {"v": {}});
    };
    return _parseNumber(s, i);
};

dict fn jsonParseAny(str s) {
    dict r = _parseValue(s, 0);
    int j = _skip(s, r["i"]);
    if (j != len(s)) {
        throw JsonError("trailing data at " + j);
    };
    return {"value": r["v"]};
};

export dict fn json(str s) {
    dict container = jsonParseAny(s);
    return container["value"];
};

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

    if (numberOfPatterns != numberOfReplacements) {
      str message = replace(
          replace("Number of patterns (%numberOfPatterns%) and replacements (%numberOfReplacements%) must be equal.", "%numberOfPatterns%", "" + numberOfPatterns),
          "%numberOfReplacements%", "" + numberOfReplacements
       );
       throw StringError(message);
    };

    int i = 0;
    while (i < numberOfPatterns) {
      invalue = replace(invalue, patterns[i], replacements[i]);
      i = i + 1;
    };
    return invalue;
};


void fn installDeps(str depsFile) {
  dict depsValue = json(read(depsFile));
  dict depsMap = depsValue["dependencies"];

  cmd("rm -rf teahouse");
  cmd("mkdir -p teahouse");

  array depNames = dictKeys(depsMap);
  for (int i = 0; i < len(depNames); i = i + 1) {
      str depName = depNames[i];
      dict depInfo = depsMap[depName];
      str depOrigin = depInfo["origin"];
      if (len(split(depOrigin, "://")) > 1) {
        str command = "wget " + depOrigin + " -O " + "teahouse/" + depName + ".t";
        cmd(command);
      } else {
        str command = "cp -r " + depOrigin + " " + "teahouse/" + depName;
        cmd(command);
      };
      print("Installed dependency: ", depName);
  };
};

void fn startup() {
    str arg2 = SYSARGS[2];
    if (arg2 == "-h" or arg2 == "--help") {
        print("help is on the way..");
    };
    if (arg2 == "-i" or arg2 == "--install") {
        str depsFile = "deps.json";
        if (len(SYSARGS) > 3) {
            depsFile = SYSARGS[3];
        };
        print("Installing dependencies from ", depsFile);
        installDeps(depsFile);
    };
};
