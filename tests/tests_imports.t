int testCount = 0;

import "imports/exported.t";
import "imports/exported.t";
import "imports/reexport.t";
import "imports/reexport.t";

void fn test_explicit_import() {
    assert(exportedHelper(), "hidden");
    testCount = testCount + 1;
};

void fn test_relative_nested_import() {
    assert(nestedExport(), "hidden");
    testCount = testCount + 1;
};

test_explicit_import();
test_relative_nested_import();

print("Run ", testCount, " tests successfully (test_imports.t)");
