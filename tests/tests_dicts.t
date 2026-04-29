int testCount = 0;

void fn test_dict_literal_and_index() {
    dict user = {"name": "tea", "year": 2026};
    assert(user["name"], "tea");
    assert(user["year"], 2026);
    testCount = testCount + 1;
};

void fn test_dict_with_identifier_keys() {
    dict languages = {name: "tea", language: "tea2"};
    assert(languages["name"], "tea");
    assert(languages["language"], "tea2");
    testCount = testCount + 1;
};

void fn test_len_with_dict() {
    dict config = {"a": 1, "b": 2, "c": 3};
    assert(len(config), 3);
    testCount = testCount + 1;
};

void fn test_dict_equality() {
    dict left = {"a": 1, "b": 2};
    dict right = {"b": 2, "a": 1};
    assert(left, right);
    testCount = testCount + 1;
};

void fn test_keys_and_values() {
    dict user = {"name": "tea", "year": 2026};
    assert(dictKeys(user), ["name", "year"]);
    assert(dictValues(user), ["tea", 2026]);
    testCount = testCount + 1;
};

test_dict_literal_and_index();
test_dict_with_identifier_keys();
test_len_with_dict();
test_dict_equality();
test_keys_and_values();

print("Run ", testCount, " tests successfully (test_dicts.t)");
