#!../tea
import "../common/json.t";

str depsFile = "deps.json";

dict depsJson = jsonParseAny(read(depsFile));
dict depsValue = depsJson["value"];
dict depsMap = depsValue["dependencies"];

cmd("rm -rf teahouse");
cmd("mkdir -p teahouse");

array depNames = dictKeys(depsMap);
for (int i = 0; i < len(depNames); i = i + 1) {
    str depName = depNames[i];
    dict depInfo = depsMap[depName];
    str depOrigin = depInfo["origin"];
    str command = "cp -r " + depOrigin + " " + "teahouse/" + depName;
    cmd(command);
    print("Installed dependency: ", depName);
};
