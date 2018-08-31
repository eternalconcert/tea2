#include <map>
#include "exceptions.h"


enum typeId {INT, FLOAT, STR, BOOL, VOID, ARRAY, IDENTIFIER};

class AstNode {
};


class Constant {
public:
    typeId type;
    std::string ident;

    int intValue;
    float floatValue;
    char *stringValue;
    char *boolValue;

    void repr() {
        switch (this->type) {
            case INT:
                printf("%d\n", intValue);
                break;

            case FLOAT:
                printf("%f\n", floatValue);
                break;

            case STR:
                printf("%s\n", stringValue);
                break;

            case BOOL:
                printf("%s\n", boolValue);
                break;
        };
    };
};

class Identifier: public AstNode {};

class Expression: public AstNode {
    AstNode leftValue;
    AstNode rightValue;
};

class Assignment: public AstNode {
public:
    Identifier leftValue;
    Expression rightValue;
};
