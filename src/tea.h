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
        bool bool_value;
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
            new_constant.bool_value = strcmp(bool_value, "true") == 0;
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
        Scope *prev = NULL;
};


Scope *scopeHead = NULL;


Scope *pushScope() {
    printf("%s\n", "PUSH SCOPE");
    Scope *new_scope = new Scope();
    new_scope->prev = scopeHead;
    scopeHead = new_scope;
};


Scope *popScope() {
    printf("%s\n", "POP SCOPE");
    Scope *oldScope = scopeHead;
    scopeHead = scopeHead->prev;
    delete oldScope;
};
