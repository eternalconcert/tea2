#include "exceptions.h"
#include "valuestore.h"

Value *ValueStore::get(const std::string ident) {
    auto it = values.find(ident);
    if (it != values.end()) {
        return it->second;  // existiert
    } else {
        return nullptr;     // existiert nicht
    }
}
