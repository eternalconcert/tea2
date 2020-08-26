#include "utils.h"

std::string exec(const char* command) {
  std::array<char, 128> buffer;
  std::string result;
  FILE *ptr = popen(command, "r");

  while (fgets(buffer.data(), buffer.size(), ptr) != NULL) {
    result += buffer.data();
  }
  int rc = WEXITSTATUS(pclose(ptr));
  System *sys = System::getSystem();
  sys->lastRc = rc;
  return result;
}