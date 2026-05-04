void fn print(...arguments) {
  for (int i = 0; i < len(arguments); i = i + 1) {
        sysprint(arguments[i]);
    };
    return sysprint("\n");
};


// for (int i = 0; i < len(SYSARGS); i = i + 1) {
//     print("SYSARG ", i, ": ", SYSARGS[i]);
// };
