#include <map>
#include "exceptions.h"


enum TYPE_ID {INT, FLOAT, STR, BOOL, VOID, ARRAY};

class ValueStore {
    public:
        std::string ident;
        TYPE_ID type;
        int int_value;
        float float_value;
        char *string_value;
        char *bool_value;
        void repr();
};

void ValueStore::repr() {
    switch(type) {
        case INT:
            printf("%d\n", int_value);
            break;

        case FLOAT:
            printf("%f\n", float_value);
            break;

        case STR:
            printf("%s\n", string_value);
            break;

        case BOOL:
            printf("%s\n", bool_value);
            break;

        case VOID:
            printf("<VOID>\n");
            break;

        case ARRAY:
            printf("<ARRAY>\n");
            break;
        };
};

std::map <std::string, ValueStore> constants;

class Scope {
    public:
        std::map <std::string, ValueStore> variables;
        int index;
        Scope *parent = NULL;
};


Scope *scopeHead = NULL;


Scope *pushScope() {
    Scope *new_scope = new Scope();
    new_scope->parent = scopeHead;
    new_scope->index = 0;
    if (new_scope->parent) {
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
    scopeHead = scopeHead->parent;
    oldScope->variables.clear();
    delete oldScope;
};


ValueStore getVariable(Scope *scope, std::string ident) {
    if (scope->variables.find(ident) != scope->variables.end()) {
        return scope->variables[ident];
    }

    if (scope->parent != NULL) {
        return getVariable(scope->parent, ident);
    }
    throw RuntimeError("Undeclared identifier: " + ident);
}


ValueStore getFromValueStore(std::string ident) {
        if (constants.find(ident) != constants.end()) {
            ValueStore constant = constants[ident];
            return constant;
        }

        Scope *scope = getScopeHead();
        ValueStore variable = getVariable(scope, ident);
        return variable;
}


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
