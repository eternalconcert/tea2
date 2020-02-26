#include "exceptions.h"
#include "valuestore.h"

ValueStore* ValueStore::_constGlobalInstance = 0;

Value *ValueStore::get(std::string ident) {
    return this->values[ident];
}


ValueStore *ValueStore::getConstGlobalStore() {
    if (_constGlobalInstance == 0) {
        _constGlobalInstance = new ValueStore();
    }
    return _constGlobalInstance;
}


Value *getConstant(std::string identifier) {
    ValueStore *constGlobal = ValueStore::getConstGlobalStore();
    Value *constant = constGlobal->get(identifier);
    return constant;
}

bool isConstant(std::string identifier) {
    ValueStore *constGlobal = ValueStore::getConstGlobalStore();
    return (constGlobal->values.find(identifier) != constGlobal->values.end());
}

void checkConstant(std::string identifier) {
    ValueStore *constGlobal = ValueStore::getConstGlobalStore();
    if (isConstant(identifier) && constGlobal->get(identifier)) {
        throw (ConstError(identifier));
    }
}
