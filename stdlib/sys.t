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

export dict fn request(dict req) {
    return http(req);
};

export dict fn get(str url) {
    return http({method: "GET", url: url, headers: {}, body: ""});
};

export dict fn post(str url, str body) {
    return http({
        method: "POST",
        url: url,
        headers: {"Content-Type": "application/json"},
        body: body
    });
};

export dict fn put(str url, str body) {
    return http({
        method: "PUT",
        url: url,
        headers: {"Content-Type": "application/json"},
        body: body
    });
};

export dict fn patch(str url, str body) {
    return http({
        method: "PATCH",
        url: url,
        headers: {"Content-Type": "application/json"},
        body: body
    });
};

export dict fn delete(str url) {
    return http({method: "DELETE", url: url, headers: {}, body: ""});
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

bool fn _regexHasAt(str chars, str c) {
    return len(find(chars, c)) > 0;
};

int fn _regexIndexOf(str chars, str c) {
    array indexes = find(chars, c);
    if (len(indexes) > 0) {
        return indexes[0];
    };
    return -1;
};

int fn _regexCharCode(str c) {
    int digit = _regexIndexOf("0123456789", c);
    if (digit >= 0) {
        return 48 + digit;
    };

    int upper = _regexIndexOf("ABCDEFGHIJKLMNOPQRSTUVWXYZ", c);
    if (upper >= 0) {
        return 65 + upper;
    };

    int lower = _regexIndexOf("abcdefghijklmnopqrstuvwxyz", c);
    if (lower >= 0) {
        return 97 + lower;
    };

    return -1;
};

bool fn _regexBetween(str c, str from, str to) {
    int cCode = _regexCharCode(c);
    int fromCode = _regexCharCode(from);
    int toCode = _regexCharCode(to);

    if (cCode < 0 || fromCode < 0 || toCode < 0) {
        return false;
    };

    return cCode >= fromCode && cCode <= toCode;
};

bool fn _regexIsDigit(str c) {
    return _regexHasAt("0123456789", c);
};

bool fn _regexIsWord(str c) {
    return _regexHasAt("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_", c);
};

bool fn _regexIsSpace(str c) {
    return c == " " || c == "\n" || c == "\t" || c == "\r";
};

str fn _regexEscapedChar(str c) {
    if (c == "n") { return "\n"; };
    if (c == "t") { return "\t"; };
    if (c == "r") { return "\r"; };
    return c;
};

bool fn _regexEscapedMatches(str escape, str c) {
    if (escape == "d") { return _regexIsDigit(c); };
    if (escape == "D") { return _regexIsDigit(c) == false; };
    if (escape == "w") { return _regexIsWord(c); };
    if (escape == "W") { return _regexIsWord(c) == false; };
    if (escape == "s") { return _regexIsSpace(c); };
    if (escape == "S") { return _regexIsSpace(c) == false; };
    return _regexEscapedChar(escape) == c;
};

int fn _regexClassEnd(str pattern, int pi) {
    int i = pi + 1;
    while (i < len(pattern)) {
        if (_jc(pattern, i) == "\\") {
            i = i + 2;
            continue;
        };
        if (_jc(pattern, i) == "]") {
            return i + 1;
        };
        i = i + 1;
    };
    throw RegexError("unterminated character class at " + pi);
    return pi;
};

int fn _regexAtomEnd(str pattern, int pi) {
    if (pi >= len(pattern)) {
        throw RegexError("expected regex atom at " + pi);
    };

    str c = _jc(pattern, pi);
    if (c == "\\") {
        if (pi + 1 >= len(pattern)) {
            throw RegexError("dangling escape at " + pi);
        };
        return pi + 2;
    };

    if (c == "[") {
        return _regexClassEnd(pattern, pi);
    };

    return pi + 1;
};

dict fn _regexClassToken(str pattern, int i, int endIndex) {
    if (i >= endIndex) {
        throw RegexError("expected character class token at " + i);
    };

    if (_jc(pattern, i) == "\\") {
        if (i + 1 >= endIndex) {
            throw RegexError("dangling escape in character class at " + i);
        };
        return {"c": _regexEscapedChar(_jc(pattern, i + 1)), "i": i + 2};
    };

    return {"c": _jc(pattern, i), "i": i + 1};
};

bool fn _regexClassContains(str c, str pattern, int pi) {
    int endIndex = _regexClassEnd(pattern, pi) - 1;
    int i = pi + 1;
    bool negated = false;

    if (i < endIndex) {
        if (_jc(pattern, i) == "^") {
            negated = true;
            i = i + 1;
        };
    };

    bool matched = false;
    while (i < endIndex) {
        if (_jc(pattern, i) == "\\" && i + 1 < endIndex) {
            str escape = _jc(pattern, i + 1);
            if (_regexEscapedMatches(escape, c)) {
                matched = true;
            };
            i = i + 2;
            continue;
        };

        dict first = _regexClassToken(pattern, i, endIndex);
        str from = first["c"];
        int next = first["i"];

        if (next < endIndex) {
            if (_jc(pattern, next) == "-" && next + 1 < endIndex) {
                dict last = _regexClassToken(pattern, next + 1, endIndex);
                str to = last["c"];
                if (_regexBetween(c, from, to)) {
                    matched = true;
                };
                i = last["i"];
                continue;
            };
        };

        if (from == c) {
            matched = true;
        };
        i = next;
    };

    if (negated) {
        return matched == false;
    };
    return matched;
};

bool fn _regexAtomMatches(str invalue, int si, str pattern, int pi) {
    if (si >= len(invalue)) {
        return false;
    };

    str p = _jc(pattern, pi);
    str c = _jc(invalue, si);

    if (p == ".") {
        return true;
    };

    if (p == "\\") {
        return _regexEscapedMatches(_jc(pattern, pi + 1), c);
    };

    if (p == "[") {
        return _regexClassContains(c, pattern, pi);
    };

    return p == c;
};

bool fn _regexRepeatMatches(str invalue, int si, str pattern, int atomStart, int afterQuantifier) {
    if (_regexFrom(invalue, si, pattern, afterQuantifier)) {
        return true;
    };

    int current = si;
    while (_regexAtomMatches(invalue, current, pattern, atomStart)) {
        current = current + 1;
        if (_regexFrom(invalue, current, pattern, afterQuantifier)) {
            return true;
        };
    };

    return false;
};

bool fn _regexGroupMatches(str invalue, int si, str pattern, int groupStart, int groupEnd) {
    str groupPattern = getSubstring(pattern, groupStart + 1, groupEnd);
    dict groupMatch = _regexMaxEndFrom(invalue, si, groupPattern, 0, len(groupPattern));
    if (groupMatch["ok"] == false) {
        return false;
    };

    int candidateEnd = groupMatch["i"];
    while (candidateEnd >= si) {
        str candidate = getSubstring(invalue, si, candidateEnd);
        if (regexMatch(candidate, groupPattern)) {
            if (_regexFrom(invalue, candidateEnd, pattern, groupEnd + 1)) {
                return true;
            };
        };
        candidateEnd = candidateEnd - 1;
    };

    return false;
};

bool fn _regexFrom(str invalue, int si, str pattern, int pi) {
    if (pi >= len(pattern)) {
        return true;
    };

    str p = _jc(pattern, pi);
    if (p == "^") {
        if (si != 0) {
            return false;
        };
        return _regexFrom(invalue, si, pattern, pi + 1);
    };

    if (p == "$" && pi + 1 == len(pattern)) {
        return si == len(invalue);
    };

    if (p == "(") {
        int groupEnd = _regexGroupEnd(pattern, pi);
        return _regexGroupMatches(invalue, si, pattern, pi, groupEnd);
    };

    int atomEnd = _regexAtomEnd(pattern, pi);
    if (atomEnd < len(pattern)) {
        str quantifier = _jc(pattern, atomEnd);

        if (quantifier == "*") {
            return _regexRepeatMatches(invalue, si, pattern, pi, atomEnd + 1);
        };

        if (quantifier == "+") {
            if (_regexAtomMatches(invalue, si, pattern, pi) == false) {
                return false;
            };
            return _regexRepeatMatches(invalue, si + 1, pattern, pi, atomEnd + 1);
        };

        if (quantifier == "?") {
            if (_regexFrom(invalue, si, pattern, atomEnd + 1)) {
                return true;
            };
            if (_regexAtomMatches(invalue, si, pattern, pi)) {
                return _regexFrom(invalue, si + 1, pattern, atomEnd + 1);
            };
            return false;
        };
    };

    if (_regexAtomMatches(invalue, si, pattern, pi) == false) {
        return false;
    };

    return _regexFrom(invalue, si + 1, pattern, atomEnd);
};

bool fn _regexEndsWithEndAnchor(str pattern) {
    if (len(pattern) == 0) {
        return false;
    };
    return _jc(pattern, len(pattern) - 1) == "$";
};

int fn _regexGroupEnd(str pattern, int pi) {
    int i = pi + 1;
    while (i < len(pattern)) {
        str c = _jc(pattern, i);
        if (c == "\\") {
            i = i + 2;
            continue;
        };
        if (c == "[") {
            i = _regexClassEnd(pattern, i);
            continue;
        };
        if (c == "(") {
            throw RegexError("nested capture groups are not supported at " + i);
        };
        if (c == ")") {
            return i;
        };
        i = i + 1;
    };
    throw RegexError("unterminated capture group at " + pi);
    return pi;
};

array fn _regexAppendGroup(array groups, str value) {
    array out = [];
    int i = 0;
    while (i < len(groups)) {
        out[len(out)] = groups[i];
        i = i + 1;
    };
    out[len(out)] = value;
    return out;
};

dict fn _regexCaptureResult(bool ok, int i, array groups) {
    return {"ok": ok, "i": i, "groups": groups};
};

dict fn _regexEndResult(bool ok, int i) {
    return {"ok": ok, "i": i};
};

dict fn _regexMaxEndRepeatMatches(str invalue, int si, str pattern, int atomStart, int afterQuantifier, int endPi) {
    int current = si;
    while (_regexAtomMatches(invalue, current, pattern, atomStart)) {
        current = current + 1;
    };

    while (current >= si) {
        dict rest = _regexMaxEndFrom(invalue, current, pattern, afterQuantifier, endPi);
        if (rest["ok"]) {
            return rest;
        };
        current = current - 1;
    };

    return _regexEndResult(false, si);
};

dict fn _regexMaxEndFrom(str invalue, int si, str pattern, int pi, int endPi) {
    if (pi >= endPi) {
        return _regexEndResult(true, si);
    };

    str p = _jc(pattern, pi);
    if (p == "^") {
        if (si != 0) {
            return _regexEndResult(false, si);
        };
        return _regexMaxEndFrom(invalue, si, pattern, pi + 1, endPi);
    };

    if (p == "$" && pi + 1 == endPi) {
        return _regexEndResult(si == len(invalue), si);
    };

    int atomEnd = _regexAtomEnd(pattern, pi);
    if (atomEnd < endPi) {
        str quantifier = _jc(pattern, atomEnd);

        if (quantifier == "*") {
            return _regexMaxEndRepeatMatches(invalue, si, pattern, pi, atomEnd + 1, endPi);
        };

        if (quantifier == "+") {
            if (_regexAtomMatches(invalue, si, pattern, pi) == false) {
                return _regexEndResult(false, si);
            };
            return _regexMaxEndRepeatMatches(invalue, si + 1, pattern, pi, atomEnd + 1, endPi);
        };

        if (quantifier == "?") {
            if (_regexAtomMatches(invalue, si, pattern, pi)) {
                dict matched = _regexMaxEndFrom(invalue, si + 1, pattern, atomEnd + 1, endPi);
                if (matched["ok"]) {
                    return matched;
                };
            };
            return _regexMaxEndFrom(invalue, si, pattern, atomEnd + 1, endPi);
        };
    };

    if (_regexAtomMatches(invalue, si, pattern, pi) == false) {
        return _regexEndResult(false, si);
    };

    return _regexMaxEndFrom(invalue, si + 1, pattern, atomEnd, endPi);
};

dict fn _regexCaptureRepeatMatches(str invalue, int si, str pattern, int atomStart, int afterQuantifier, int endPi, array groups) {
    dict rest = _regexCaptureFrom(invalue, si, pattern, afterQuantifier, endPi, groups);
    if (rest["ok"]) {
        return rest;
    };

    int current = si;
    while (_regexAtomMatches(invalue, current, pattern, atomStart)) {
        current = current + 1;
        rest = _regexCaptureFrom(invalue, current, pattern, afterQuantifier, endPi, groups);
        if (rest["ok"]) {
            return rest;
        };
    };

    return _regexCaptureResult(false, si, groups);
};

dict fn _regexCaptureGroup(str invalue, int si, str pattern, int groupStart, int groupEnd, int endPi, array groups) {
    if (groupEnd + 1 < endPi) {
        str quantifier = _jc(pattern, groupEnd + 1);
        if (quantifier == "*" || quantifier == "+" || quantifier == "?") {
            throw RegexError("quantified capture groups are not supported at " + groupStart);
        };
    };

    str groupPattern = getSubstring(pattern, groupStart + 1, groupEnd);
    dict groupMatch = _regexMaxEndFrom(invalue, si, groupPattern, 0, len(groupPattern));
    if (groupMatch["ok"] == false) {
        return _regexCaptureResult(false, si, groups);
    };

    int candidateEnd = groupMatch["i"];
    while (candidateEnd >= si) {
        str candidate = getSubstring(invalue, si, candidateEnd);
        if (regexMatch(candidate, groupPattern)) {
            array nextGroups = _regexAppendGroup(groups, candidate);
            dict rest = _regexCaptureFrom(invalue, candidateEnd, pattern, groupEnd + 1, endPi, nextGroups);
            if (rest["ok"]) {
                return rest;
            };
        };
        candidateEnd = candidateEnd - 1;
    };

    return _regexCaptureResult(false, si, groups);
};

dict fn _regexCaptureFrom(str invalue, int si, str pattern, int pi, int endPi, array groups) {
    if (pi >= endPi) {
        return _regexCaptureResult(true, si, groups);
    };

    str p = _jc(pattern, pi);
    if (p == "^") {
        if (si != 0) {
            return _regexCaptureResult(false, si, groups);
        };
        return _regexCaptureFrom(invalue, si, pattern, pi + 1, endPi, groups);
    };

    if (p == "$" && pi + 1 == endPi) {
        return _regexCaptureResult(si == len(invalue), si, groups);
    };

    if (p == "(") {
        int groupEnd = _regexGroupEnd(pattern, pi);
        return _regexCaptureGroup(invalue, si, pattern, pi, groupEnd, endPi, groups);
    };

    int atomEnd = _regexAtomEnd(pattern, pi);
    if (atomEnd < endPi) {
        str quantifier = _jc(pattern, atomEnd);

        if (quantifier == "*") {
            return _regexCaptureRepeatMatches(invalue, si, pattern, pi, atomEnd + 1, endPi, groups);
        };

        if (quantifier == "+") {
            if (_regexAtomMatches(invalue, si, pattern, pi) == false) {
                return _regexCaptureResult(false, si, groups);
            };
            return _regexCaptureRepeatMatches(invalue, si + 1, pattern, pi, atomEnd + 1, endPi, groups);
        };

        if (quantifier == "?") {
            dict skipped = _regexCaptureFrom(invalue, si, pattern, atomEnd + 1, endPi, groups);
            if (skipped["ok"]) {
                return skipped;
            };
            if (_regexAtomMatches(invalue, si, pattern, pi)) {
                return _regexCaptureFrom(invalue, si + 1, pattern, atomEnd + 1, endPi, groups);
            };
            return _regexCaptureResult(false, si, groups);
        };
    };

    if (_regexAtomMatches(invalue, si, pattern, pi) == false) {
        return _regexCaptureResult(false, si, groups);
    };

    return _regexCaptureFrom(invalue, si + 1, pattern, atomEnd, endPi, groups);
};

export bool fn regexTest(str invalue, str pattern) {
    if (len(pattern) > 0) {
        if (_jc(pattern, 0) == "^") {
            return _regexFrom(invalue, 0, pattern, 0);
        };
    };

    int i = 0;
    while (i <= len(invalue)) {
        if (_regexFrom(invalue, i, pattern, 0)) {
            return true;
        };
        i = i + 1;
    };

    return false;
};

export bool fn regexMatch(str invalue, str pattern) {
    str anchoredPattern = pattern;
    if (_regexEndsWithEndAnchor(pattern) == false) {
        anchoredPattern = pattern + "$";
    };
    return _regexFrom(invalue, 0, anchoredPattern, 0);
};

export array fn regexFind(str invalue, str pattern) {
    array matches = [];
    int i = 0;
    while (i <= len(invalue)) {
        if (_regexFrom(invalue, i, pattern, 0)) {
            matches[len(matches)] = i;
        };
        i = i + 1;
    };
    return matches;
};

export bool fn regex(str invalue, str pattern) {
    return regexTest(invalue, pattern);
};

str fn _regexLiteralPrefix(str pattern) {
    str prefix = "";
    int i = 0;
    while (i < len(pattern)) {
        str c = _jc(pattern, i);
        int next = i + 1;
        str literal = "";

        if (c == "^") {
            if (i == 0) {
                i = i + 1;
                continue;
            };
            return prefix;
        };

        if (c == "\\" && i + 1 < len(pattern)) {
            str escape = _jc(pattern, i + 1);
            if (escape == "d" || escape == "D" || escape == "w" || escape == "W" || escape == "s" || escape == "S") {
                return prefix;
            };
            literal = _regexEscapedChar(escape);
            next = i + 2;
        } else {
            if (c == "." || c == "[" || c == "(" || c == "$") {
                return prefix;
            };
            literal = c;
        };

        if (next < len(pattern)) {
            str quantifier = _jc(pattern, next);
            if (quantifier == "*" || quantifier == "+" || quantifier == "?") {
                return prefix;
            };
        };

        prefix = prefix + literal;
        i = next;
    };
    return prefix;
};

export array fn regexCapture(str invalue, str pattern) {
    array emptyGroups = [];
    if (len(pattern) > 0) {
        if (_jc(pattern, 0) == "^") {
            dict anchored = _regexCaptureFrom(invalue, 0, pattern, 0, len(pattern), emptyGroups);
            if (anchored["ok"]) {
                return anchored["groups"];
            };
            return [];
        };
    };

    str prefix = _regexLiteralPrefix(pattern);
    if (len(prefix) > 0) {
        array startIndexes = find(invalue, prefix);
        int startIndex = 0;
        while (startIndex < len(startIndexes)) {
            dict result = _regexCaptureFrom(invalue, startIndexes[startIndex], pattern, 0, len(pattern), emptyGroups);
            if (result["ok"]) {
                return result["groups"];
            };
            startIndex = startIndex + 1;
        };
        return [];
    };

    int i = 0;
    while (i <= len(invalue)) {
        dict result = _regexCaptureFrom(invalue, i, pattern, 0, len(pattern), emptyGroups);
        if (result["ok"]) {
            return result["groups"];
        };
        i = i + 1;
    };

    return [];
};

export array fn regexCaptureAll(str invalue, str pattern) {
    array matches = [];
    array emptyGroups = [];

    if (len(pattern) > 0) {
        if (_jc(pattern, 0) == "^") {
            dict anchored = _regexCaptureFrom(invalue, 0, pattern, 0, len(pattern), emptyGroups);
            if (anchored["ok"]) {
                matches[len(matches)] = anchored["groups"];
            };
            return matches;
        };
    };

    int i = 0;
    str prefix = _regexLiteralPrefix(pattern);
    if (len(prefix) > 0) {
        array startIndexes = find(invalue, prefix);
        int minStart = 0;
        int startIndex = 0;
        while (startIndex < len(startIndexes)) {
            int start = startIndexes[startIndex];
            if (start >= minStart) {
                dict result = _regexCaptureFrom(invalue, start, pattern, 0, len(pattern), emptyGroups);
                if (result["ok"]) {
                    matches[len(matches)] = result["groups"];
                    int next = result["i"];
                    if (next <= start) {
                        minStart = start + 1;
                    } else {
                        minStart = next;
                    };
                };
            };
            startIndex = startIndex + 1;
        };
        return matches;
    };

    while (i <= len(invalue)) {
        dict result = _regexCaptureFrom(invalue, i, pattern, 0, len(pattern), emptyGroups);
        if (result["ok"]) {
            matches[len(matches)] = result["groups"];
            int next = result["i"];
            if (next <= i) {
                i = i + 1;
            } else {
                i = next;
            };
        } else {
            i = i + 1;
        };
    };

    return matches;
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
        str command = "wget " + depOrigin + " -O " + "teahouse/" + depName + ".t --no-check-certificate";
        str result = cmd(command);
        print(result);
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
