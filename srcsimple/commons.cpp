#include <string>
#include <commons.h>



typeId getTypeIdByName(std::string name) {

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

std::string getTypeNameById(typeId id) {

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
