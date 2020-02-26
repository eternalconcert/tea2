#ifndef VALUESTORE_H
#define VALUESTORE_H
#include <map>
#include <string>
#include "value.h"

class ValueStore {
    public:
        std::map <std::string, Value*> values;

        void set(std::string ident, Value* val) {
            this->values[ident] = val;
        }

        Value *get(std::string ident);

        static ValueStore *getConstGlobalStore();

    private:
        static ValueStore *_constGlobalInstance;
};


Value *getConstant(std::string identifier);
bool isConstant(std::string identifier);
void checkConstant(std:: string identifier);
#endif
