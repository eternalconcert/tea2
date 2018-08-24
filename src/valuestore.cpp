#include <map>
#include "exceptions.h"


enum TYPE_ID {INT, FLOAT, STR, BOOL, VOID, ARRAY, IDENTIFIER};

TYPE_ID getTypeIdByName(std::string name) {

    if (name == "INT"){
        return INT;
    }

    if (name == "FLOAT"){
        return FLOAT;
    }

    if (name == "STR"){
        return STR;
    }

    if (name == "BOOL"){
        return BOOL;
    }

    if (name == "IDENTIFIER") {
        return IDENTIFIER;
    }
};

std::string getTypeNameById(TYPE_ID id) {

    switch (id) {
        case INT:
            return "INT";

        case FLOAT:
            return "FLOAT";

        case STR:
            return "STR";

        case BOOL:
            return "BOOL";

        case VOID:
            return "VOID";

        case ARRAY:
            return "ARRAY";

        case IDENTIFIER:
            return "IDENTIFIER";
    };
};

class ValueStore {
    public:
        std::string ident;
        TYPE_ID type;
        bool assigned = true;
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
        if (!variable.assigned) {
            throw RuntimeError(ident + " has been declared but not assigned");
        }
        return variable;
};


void makeEmptyVariable(Scope *scope, std::string ident, TYPE_ID type) {
    ValueStore variable = ValueStore();
    variable.ident = ident;
    variable.type = type;
    variable.assigned = false;
    scope->variables[ident] = variable;
};


ValueStore makeValue(std::string ident, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value) {
    ValueStore value = ValueStore();
    value.ident = ident;
    value.type = type;

    switch(type) {
        case INT:
            value.int_value = int_value;
            break;

        case FLOAT:
            value.float_value = float_value;
            break;

        case STR:
            value.string_value = string_value;
            break;

        case BOOL:
            value.bool_value = bool_value;
            break;

        case IDENTIFIER:
            printf("Die Idee ist: Die Variable nimmt nur den WERT der anderen an und wird nicht zu der anderen.\n");
            getFromValueStore("identifier");
            break;

        case VOID:
            break;

        case ARRAY:
            break;
        };

    return value;

};


void addConstant(std::string ident, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value) {

    if (constants.find(ident) != constants.end()) {
        throw RuntimeError("Constant redaclared: " + ident);
    }

    ValueStore new_constant = makeValue(ident, type, int_value, float_value, string_value, bool_value);
    constants[ident] = new_constant;
};


void addVariable(Scope *scope, std::string ident, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value) {
        ValueStore new_variable = makeValue(ident, type, int_value, float_value, string_value, bool_value);
        scope->variables[ident] = new_variable;
};

void updateVariable(Scope *scope, std::string ident, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value) {
    ValueStore variable = getVariable(scope, ident);
    if (variable.type != type) {
        throw RuntimeError("Type mismatch: " + ident + " == " + getTypeNameById(variable.type) + " != " + getTypeNameById(type));
    }

    variable.int_value = int_value;
    variable.float_value = float_value;
    variable.string_value = string_value;
    variable.bool_value = bool_value;
    variable.assigned = true;
    scope->variables[ident] = variable;
};
