#include <string>
#include <array>

std::string exec(const char* command);

class System {
  public:
      int argc;
      std::array<char*, 128> args;
      int lastRc;
      static System *getSystem();
      void setSystem(int argc, char **args);
  private:
    static System *_SystemInstance;
};
