#include "utils.h"
#include <string.h>

std::string exec(const char* command) {
  std::array<char, 128> buffer;
  std::string result;
  char* cStr = new char[strlen(command) + sizeof(char) * 6];
  strcpy(cStr, command);
  strcat(cStr, " 2>&1");
  FILE *ptr = popen(cStr, "r");

  while (fgets(buffer.data(), buffer.size(), ptr) != NULL) {
    result += buffer.data();
  }
  int rc = WEXITSTATUS(pclose(ptr));
  System *sys = System::getSystem();
  sys->lastRc = rc;
  return result;
}