// Auto-generated from stdlib/sys.t - do not edit manually
#ifndef INIT_CODE_H
#define INIT_CODE_H

const char* INIT_CODE = "void fn print(...arguments) {\n  for (int i = 0; i < len(arguments); i = i + 1) {\n        sysprint(arguments[i]);\n    };\n    return sysprint(\"\\n\");\n};\n\n\n// for (int i = 0; i < len(SYSARGS); i = i + 1) {\n//     print(\"SYSARG \", i, \": \", SYSARGS[i]);\n// };\n";

#endif
