#include <string>
#include "ast.h"


std::string getNodeTypeName(nodeType type) {
    switch(type) {
        case ADD:
            return "ADD";
        case SUB:
            return "SUB";
        case MUL:
            return "MUL";
        case DIV:
            return "DIV";
        case INT:
            return "INT";
        case FLOAT:
            return "FLOAT";
        case STR:
            return "STR";
        case BOOL:
            return "BOOL";
    }
};

AstNode::AstNode(nodeType type) {
    this->type = type;
    printf("nodeType: %i\n", this->type);
};
