PR.registerLangHandler(
    PR.createSimpleLexer(
        [
          [PR.PR_STRING,        /^(?:"(?:[^\\"\r\n]|\\.)*(?:"|$))/, null, '"'],
        ],
        [ [PR.PR_COMMENT,       /^#[^\r\n]*/, null],

          [PR.PR_KEYWORD,       /^\b(?:CONST|VAR|FN|return|for|if|else|true|false)\b/, null],
          [PR.PR_TYPE,          /^\b(?:INT|FLOAT|STR|BOOL|ARRAY|VOID)\b/, null],
          [PR.PR_PLAIN,         /^[A-Z][A-Z0-9]?(?:\$|%|)?/i, null],
          [PR.PR_LITERAL,       /^(?:\d+(?:\.\d*)?|\.\d+)(?:e[+\-]?\d+)?/i,  null, '0123456789'],
          [PR.PR_PUNCTUATION,      /^[+\-/*=^&|!<>%[\](){}?:.,;]/],
        ]),
    ['tea']);
