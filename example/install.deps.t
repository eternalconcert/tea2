#!../tea
str depsFile = "deps.txt";
array deps = split(read(depsFile), "\n");

cmd("rm -rf teahouse");
cmd("mkdir -p teahouse");

for (int i = 0; i < len(deps); i = i + 1) {
    str dep = deps[i];
    if (len(dep) > 0) {
        array depParts = split(dep, ":");
        str depName = depParts[0];
        str depPath = depParts[1];
        str command = "cp -r " + depPath + " " + "teahouse/" + depName;
        cmd(command);
        print("Installed dependency: ", depParts[0]);
    };
};
