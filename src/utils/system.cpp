#include "utils.h"

System* System::_SystemInstance = 0;


System *System::getSystem() {
    if (_SystemInstance == 0) {
        _SystemInstance = new System();
    }
    return _SystemInstance;
};

void System::setSystem(int argc, char **inArgs) {
    System *instance = System::getSystem();
    for (int i = 0; i < argc; i++) {
      instance->args[i] = inArgs[i];
    }
    instance->argc = argc;
};