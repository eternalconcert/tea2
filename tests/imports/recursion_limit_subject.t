int fn recurse(int x) {
  return recurse(x + 1);
};

print(recurse(0));
