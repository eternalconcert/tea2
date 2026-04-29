int testCount = 0;

import "imports/clash_winner.t";
import "@vendor/clash_export.t";
import "@nested/pkg.t";

void fn test_teahouse_path() {
    assert(teahousePkgMarker, 42, "teahouse @ path");
    testCount = testCount + 1;
};

void fn test_teahouse_export_clash() {
    assert(sharedName, 1, "teahouse export loses to prior import");
    testCount = testCount + 1;
};

test_teahouse_path();
test_teahouse_export_clash();

print("Run ", testCount, " tests successfully (tests_teahouse_imports.t)");
