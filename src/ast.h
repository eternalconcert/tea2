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
    ExpressionNode(Value *lvalue);
    AstNode *evaluate();
};


class OperatorNode: public AstNode {
public:
    char *op;
    OperatorNode(char *op) {
        this->op = op;
    };
    AstNode *evaluate() {};

};
