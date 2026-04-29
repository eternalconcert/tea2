import "@common/json.t";
dict r = jsonParseAny("{\"a\":1,\"d\":{\"k\":2}}");
dict v = r["value"];
print("root ", dictKeys(v), "\n");
