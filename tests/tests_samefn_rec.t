dict fn build(int depth) {
    dict acc = {};
    if (depth > 0) {
        acc["inner"] = build(depth - 1);
    };
    acc["d"] = depth;
    return acc;
};
dict v = build(1);
assert(v["d"], 1);
print("tests_samefn_rec.t ok\n");
