import "@common/json.t";

dict r = jsonParseAny("{\"a\":1,\"b\":\"x\",\"c\":[],\"d\":{\"k\":2}}");
dict v = r["value"];
print("keys ", dictKeys(v), "\n");
