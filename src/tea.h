#include <map>
#include <stdexcept>


class RuntimeError: public std::exception {
    public:
        RuntimeError(std::string message) {
            printf("RuntimeError: %s\n", message.c_str());
            exit(1);
        };
};


enum TYPE_ID {INT, FLOAT, STR, BOOL, VOID, ARRAY};

class ValueStore {
    public:
        std::string ident;
        TYPE_ID type;
        int int_value;
        float float_value;
        char *string_value;
        char *bool_value;
};


std::map <std::string, ValueStore> constants;


void addConstant(std::string ident, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value) {
    ValueStore new_constant = ValueStore();
    new_constant.ident = ident;
    new_constant.type = type;

    if (constants.find(ident) != constants.end()) {
        throw RuntimeError("Constant redaclared: " + ident);
    }

    switch(type) {
        case INT:
            new_constant.int_value = int_value;
            break;

        case FLOAT:
            new_constant.float_value = float_value;
            break;

        case STR:
            new_constant.string_value = string_value;
            break;

        case BOOL:
            new_constant.bool_value = bool_value;
            break;

        case VOID:
            break;

        case ARRAY:
            break;
        };

        constants[ident] = new_constant;
};


class Scope {
    public:
        std::map <std::string, ValueStore> variables;
        int index;
        Scope *prev = NULL;
};


Scope *scopeHead = NULL;


Scope *pushScope() {
    Scope *new_scope = new Scope();
    new_scope->prev = scopeHead;
    new_scope->index = 0;
    if (new_scope->prev) {
        new_scope->index = scopeHead->index + 1;
    };
    scopeHead = new_scope;
};


Scope *getScopeHead() {
    if (scopeHead) {
        return scopeHead;
    }
    else {
        return pushScope();
    }
}


Scope *popScope() {
    Scope *oldScope = scopeHead;
    scopeHead = scopeHead->prev;
    delete oldScope;
};
