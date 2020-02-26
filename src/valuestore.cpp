#include "valuestore.h"

ValueStore* ValueStore::_constGlobalInstance = 0;

ValueStore *ValueStore::getConstGlobalStore() {
    if (_constGlobalInstance == 0) {
        _constGlobalInstance = new ValueStore();
    }
    return _constGlobalInstance;
}
