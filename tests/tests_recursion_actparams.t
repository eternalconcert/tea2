// Regression: act_params must not use addToChildList (merges with expr tree).
dict fn inner(int x) {
    return {"k": x};
};
dict fn outer() {
    dict o = {};
    o["a"] = 1;
    o["d"] = inner(2);
    return o;
};
dict v = outer();
dict d = v["d"];
assert(len(dictKeys(v)), 2);
assert(v["a"], 1);
assert(d["k"], 2);
print("tests_recursion_actparams.t ok\n");
