#ifndef SCOPE_H
#define SCOPE_H
#include <map>
#include <string>
#include "value.h"

class Scope {
    public:
        std::map <std::string, Value*> valueStore;
};

extern Scope *constGlobal;


#endif
