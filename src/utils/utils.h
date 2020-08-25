#include <cstdio>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <array>

std::string exec(const char* command);

class System {
  public:
      std::array<char*, 128> args;
      static System *getSystem();
      int argc;
      void setSystem(int argc, char **args);
  private:
    static System *_SystemInstance;
};
