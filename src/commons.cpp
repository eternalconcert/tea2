#include <string>
#include "commons.h"
#include "exceptions.h"


typeId getTypeIdByName(std::string name) {

    if (name == "INT") {
        return INT;
    }

    if (name == "FLOAT") {
        return FLOAT;
    }

    if (name == "STR") {
        return STR;
    }

    if (name == "BOOL") {
        return BOOL;
    }

    if (name == "VOID") {
        return VOID;
    }

    if (name == "IDENTIFIER") {
        return IDENTIFIER;
    }

    if (name == "FUNCTION") {
        return FUNCTION;
    }

    if (name == "FUNCTIONCALL") {
        return FUNCTIONCALL;
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

        case FUNCTION:
            return "FUNCTION";

        case FUNCTIONCALL:
            return "FUNCTIONCALL";

        default:
            throw RuntimeError("Unknown TypeId");
    };
};
