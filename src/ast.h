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


class OperantNode: public AstNode {
public:
    Value *value;
    AstNode* evaluate() {
        printf("%i\n", this->value->intValue);
    };
    OperantNode() {};
};


class OperatorNode: public AstNode {
};

class PlusNode: public OperatorNode {
public:
    AstNode *evaluate() {
        printf("%s\n", "PlusNode");
    }
};

class MinusNode: public OperatorNode {
public:
    AstNode *evaluate() {
        printf("%s\n", "MinusNode");
    }
};

class TimesNode: public OperatorNode {
public:
    AstNode *evaluate() {
        printf("%s\n", "TimesNode");
    }
};

class DivideNode: public OperatorNode {
public:
    AstNode *evaluate() {
        printf("%s\n", "DivideNode");
    }
};



class ExpressionNode: public AstNode {
public:
    Value *value;  // evaluated value
    char *op;
    ExpressionNode();
    AstNode *evaluate();
};
