int testCount = 0;

import "../common/json.t";

void fn test_object_and_array() {
    dict v = json("{\"a\":1,\"b\":\"x\",\"c\":[],\"d\":{\"k\":2}}");
    assert(v["a"], 1);
    assert(v["b"], "x");
    assert(len(v["c"]), 0);
    assert(v["d"], {"k": 2});
    testCount = testCount + 1;
};

void fn test_null_is_empty_dict() {
    dict v = json("{\"x\":null}");
    dict n = v["x"];
    assert(len(n), 0);
    testCount = testCount + 1;
};

test_object_and_array();
test_null_is_empty_dict();

print("Run ", testCount, " tests successfully (tests_json.t)");
