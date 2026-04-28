#include "utils.h"
#include <string>
#include <string.h>

std::string exec(const char* command) {
  std::array<char, 128> buffer;
  std::string result;
  std::string commandWithStderr = std::string(command) + " 2>&1";
  FILE *ptr = popen(commandWithStderr.c_str(), "r");

  while (fgets(buffer.data(), buffer.size(), ptr) != NULL) {
    result += buffer.data();
  }
  int rc = pclose(ptr);
  System *sys = System::getSystem();
  sys->lastRc = rc;
  return result;
}