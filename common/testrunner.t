array fn findTests() {
    str lsOutput = cmd("ls -1 tests/*.t");
    array files = split(lsOutput, "\n");
    array testFiles = [];
    for (int i = 0; i < len(files); i = i + 1) {
        if (len(files[i]) > 0) {
            testFiles[len(testFiles)] = files[i];
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