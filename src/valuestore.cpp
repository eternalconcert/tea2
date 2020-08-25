#include "exceptions.h"
#include "valuestore.h"

Value *ValueStore::get(std::string ident) {
    return this->values[ident];
}
