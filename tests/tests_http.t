int testCount = 0;

str pid = replace(cmd("python3 tests/http_fixture.py 18080 >/tmp/tea-http-fixture.log 2>&1 & echo $!"), "\n", "");
sleep(0.5);

dict getResponse = get("http://127.0.0.1:18080/hello?x=1");
assert(getResponse["status"], 200);
assert(getResponse["body"], "hello");
dict getHeaders = getResponse["headers"];
assert(getHeaders["content-type"], "text/plain");
testCount = testCount + 1;

dict postResponse = post("http://127.0.0.1:18080/post", "{\"ok\":true}");
assert(postResponse["status"], 201);
assert(postResponse["body"], "{\"ok\":true}");
dict body = json(postResponse["body"]);
assert(body["ok"], true);
testCount = testCount + 1;

dict binaryResponse = get("http://127.0.0.1:18080/binary");
assert(binaryResponse["status"], 200);
assert(len(binaryResponse["body"]), 11);
write("/tmp/tea-http-binary.out", binaryResponse["body"]);
str binaryFromFile = read("/tmp/tea-http-binary.out");
assert(len(binaryFromFile), 11);
assert(binaryFromFile, binaryResponse["body"]);
cmd("rm -f /tmp/tea-http-binary.out");
testCount = testCount + 1;

dict unsupported = http({method: "GET", url: "https://example.com", headers: {}, body: ""});
assert(unsupported["status"], 0);
testCount = testCount + 1;

str killCommand = "kill " + pid;
cmd(killCommand);

print("Run ", testCount, " tests successfully (tests_http.t)");
