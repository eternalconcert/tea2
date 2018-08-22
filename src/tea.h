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

class Constant {
    public:
        std::string ident;
        TYPE_ID type;
        int int_value;
        float float_value;
        char *string_value;
        bool bool_value;
};


std::map <std::string, Constant> constants;


void addConstant(std::string ident, TYPE_ID type, int int_value, float float_value, char *string_value, char *bool_value) {
    Constant new_constant = Constant();
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

