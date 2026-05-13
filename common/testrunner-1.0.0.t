import "iterable.t";

array fn skippedTests() {
  for (int i = 0; i < len(SYSARGS); i = i + 1) {
    str arg = SYSARGS[i];
    if (split(arg, "=")[0] == "--skip") {
      return split(split(arg, "=")[1], ",");
    };
  };
  return [];
};

array fn findTests() {
  array skipped = skippedTests();
  if (len(skipped) > 0) {
    print("Skipping testfiles: ", skipped, "\n");
  };
  str lsOutput = cmd("ls -1 tests/*.t");
  array files = split(lsOutput, "\n");
  array testFiles = [];
  for (int i = 0; i < len(files); i = i + 1) {
    if (len(files[i]) > 0) {
      if (arrayContains(skipped, files[i]) == false) {
        testFiles[len(testFiles)] = files[i];
      };
    };
  };
  return testFiles;
};

int retCode = 0;

print("Running tests:\n");
array testFiles = findTests();
for (int i = 0; i < len(testFiles); i = i + 1) {
  print("Running ", testFiles[i], "...\n");
  str command = "./tea " + testFiles[i] + "; echo $?";
  array result = split(cmd(command), "\n");
  if (result[1] != "0" && result[1] != "") {
    print("Test failed: ", testFiles[i], " ", result[0], "\n");
    retCode = 1;
  };
};

if (retCode == 0) {
  print("All tests passed successfully!\n");
} else {
  print("Some tests failed. Please check the output above for details.\n");
  throw TestError("Test failures detected");
};
