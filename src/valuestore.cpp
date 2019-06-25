#include <map>
#include "exceptions.h"


// Helper methods should get an own home
std::string cleanStrLit(std::string lit) {
    return lit.substr(1, lit.size() -2);
}


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
        bool constant = false;
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


class Scope {
    public:
        std::map <std::string, ValueStore> values;
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
    oldScope->values.clear();
    delete oldScope;
};


ValueStore getValue(Scope *scope, std::string ident) {
    if (scope->values.find(ident) != scope->values.end()) {
        return scope->values[ident];
    }

    if (scope->parent != NULL) {
        return getValue(scope->parent, ident);
    }
    throw RuntimeError("Undeclared identifier: " + ident);
}


ValueStore getFromValueStore(std::string ident) {
        Scope *scope = getScopeHead();
        ValueStore value = getValue(scope, ident);
        if (!value.assigned) {
            throw RuntimeError(ident + " has been declared but not assigned");
        }
        return value;
};


ValueStore makeEmptyVariable(std::string ident, TYPE_ID type) {
    Scope *scope = getScopeHead();
    ValueStore variable = ValueStore();
    variable.ident = ident;
    variable.type = type;
    variable.assigned = false;
    scope->values[ident] = variable;
    return variable;
};


ValueStore makeValue(std::string ident, bool constant, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value, char *identifier) {
    ValueStore value = ValueStore();
    value.ident = ident;
    value.type = type;
    value.constant = constant;

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
            {
                ValueStore foreignVariable = getFromValueStore(identifier);
                if (foreignVariable.type != type) {
                    throw RuntimeError("Type mismatch: " + ident + " == " + getTypeNameById(type) + " != " + getTypeNameById(foreignVariable.type));
                };
            }
            break;

        case VOID:
            break;

        case ARRAY:
            break;
        };

    return value;

};


void checkConstand(std::string ident) {
    Scope *scope = getScopeHead();
    if (scope->values.find(ident) != scope->values.end()) {
        if (scope->values[ident].constant) {
            throw RuntimeError("Constant redaclared: " + ident);
        };
    };
};

void addConstant(std::string ident, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value) {
    checkConstand(ident);
    ValueStore new_constant = makeValue(ident, true, type, int_value, float_value, string_value, bool_value, NULL);
    Scope *scope = getScopeHead();
    scope->values[ident] = new_constant;
};


void addVariable(std::string ident, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value, char *identifier) {
        checkConstand(ident);
        ValueStore new_variable = makeValue(ident, false, type, int_value, float_value, string_value, bool_value, identifier);
        Scope *scope = getScopeHead();
        scope->values[ident] = new_variable;
};

void updateVariable(std::string ident, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value, char *identifier) {
    Scope *scope = getScopeHead();
    ValueStore variable = getValue(scope, ident);

    if (type == IDENTIFIER) {
        ValueStore otherVariable = getValue(scope, identifier);
        if (variable.type != otherVariable.type) {
            throw RuntimeError("Type mismatch: Cannot assign variable (" + ident + ") of type " + getTypeNameById(variable.type) + " to variable (" + identifier + ") of type " + getTypeNameById(otherVariable.type));
        }
        type = otherVariable.type;
        scope->values[ident] = otherVariable;
        return;
    }

    if (variable.type != type) {
        throw RuntimeError("Type mismatch: " + ident + " of type " + getTypeNameById(variable.type) + " of type " + getTypeNameById(type));
    }

    variable.int_value = int_value;
    variable.float_value = float_value;
    variable.string_value = string_value;
    variable.bool_value = bool_value;
    variable.assigned = true;
    scope->values[ident] = variable;
};
