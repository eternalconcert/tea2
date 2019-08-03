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

class QuitNode: public AstNode {
public:
    int rc;
    AstNode *evaluate();
    QuitNode(int);
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
    Value *value = new Value();  // evaluated value
    char *op;

    AstNode* evaluate() {
        this->run();
        return this;
    };
    ExpressionNode *run();
};
