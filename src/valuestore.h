#ifndef VALUESTORE_H
#define VALUESTORE_H
#include <map>
#include <string>
#include "value.h"

class ValueStore {
    public:
        std::map <std::string, Value*> valueStore;

        void set(std::string ident, Value* val) {
            this->valueStore[ident] = val;
        }

        Value* get(std::string ident) {
            return this->valueStore[ident];
        }
};

extern ValueStore *constGlobal;


#endif
