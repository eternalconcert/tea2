#include <string>
#include "commons.h"
#include "value.h"


class AstNode {
public:
    int id;
    AstNode *childListHead = NULL;
    AstNode *next = NULL;
    AstNode *parent = NULL;
    void addToChildList(AstNode *newNode);
    virtual AstNode* evaluate();
    AstNode();
};


class ActParamNode: public AstNode {
public:
    Value *value;
    AstNode* evaluate();
    ActParamNode();
};

class PrintNode: public AstNode {
public:
    AstNode *evaluate();
    PrintNode(AstNode *paramsHead);
};


class ConstNode: public AstNode {
public:
    ConstNode(typeId type, char *identifier, Value *value);
    char *identifier;
    Value *value;
    AstNode *evaluate();
};


class ExpressionNode: public AstNode {
public:
    Value *value;  // evaluated value
    char *op;
    ExpressionNode() {};
    AstNode* evaluate() {
        Value *result = new Value();
        this->run(this->value);
        printf("Evaluated ");
        this->value->repr();
        printf("\n");
    };
    ExpressionNode *run(Value *currentResult);
};
