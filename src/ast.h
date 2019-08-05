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
    Value *rcValue;
    AstNode *evaluate();
    QuitNode(Value *rcValue);
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


class IfNode: public AstNode {
public:
    AstNode *elseBlock;
    AstNode *evaluate() {
        ExpressionNode *condition = (ExpressionNode*)this->childListHead->evaluate();
        if (condition->value->boolValue) {
            this->childListHead->next->evaluate();
        }
        else if (this->elseBlock != NULL) {
            elseBlock->evaluate();
        }
        return this;
    };
};
