#include <string>
#include "../commons.h"
#include "../valuestore.h"
#include "../value.h"


class AstNode {
public:
    int id;
    AstNode *childListHead = NULL;
    AstNode *next = NULL;
    AstNode *parent = NULL;
    ValueStore *valueStore;
    void addToChildList(AstNode *newNode);
    virtual AstNode* evaluate();
    AstNode();
};


class ActParamNode: public AstNode {
public:
    Value *value;
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
    AstNode *scope;
    QuitNode(Value *rcValue, AstNode *scope);
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
    AstNode *scope;
    ExpressionNode(AstNode *scope);
    AstNode* evaluate();

private:
    ExpressionNode *run();
};


class VarNode: public AstNode {
public:
    VarNode(typeId type, char *identifier, AstNode *exp, AstNode *scope);
    typeId type;
    char *identifier;
    ExpressionNode *rExp;
    AstNode *scope;
    AstNode *evaluate();
};


class VarDeclarationNode: public AstNode {
public:
    VarDeclarationNode(typeId type, char *identifier, AstNode *scope);
    typeId type;
    char *identifier;
    AstNode *scope;
    AstNode *evaluate();
};

class VarAssignmentNode: public AstNode {
public:
    VarAssignmentNode(char *identifier, AstNode *exp, AstNode *scope);
    char *identifier;
    ExpressionNode *rExp;
    AstNode *scope;
    AstNode *evaluate();
};

class IfNode: public AstNode {
public:
    AstNode *elseBlock;
    AstNode *evaluate();
};


Value *getFromValueStore(AstNode *scope, char* ident);
AstNode *getValueScope(AstNode *scope, char* ident);
