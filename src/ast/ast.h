#include <string>
#include "../commons.h"
#include "../valuestore.h"
#include "../value.h"


class AstNode {
public:
    int id;
    AstNode *childListHead = NULL;
    AstNode *parent = NULL;
    ValueStore *valueStore;
    void addToChildList(AstNode *newNode);
    virtual void evaluate();
    virtual AstNode* getNext();
    void setNext(AstNode *nextNode);
    AstNode();

private:
    AstNode *next = NULL;
};


class PrintNode: public AstNode {
public:
    void evaluate();
    PrintNode(AstNode *paramsHead);
};


class QuitNode: public AstNode {
public:
    Value *rcValue;
    void evaluate();
    AstNode *scope;
    QuitNode(Value *rcValue, AstNode *scope);
};


class ConstNode: public AstNode {
public:
    ConstNode(typeId type, char *identifier, Value *value);
    char *identifier;
    Value *value;
    void evaluate();
};


class ExpressionNode: public AstNode {
public:
    Value *value = new Value();  // evaluated value
    char *op;
    AstNode *scope;
    ExpressionNode(AstNode *scope);
    Value *runFunctionAndGetResult();
    void evaluate();
};


class VarNode: public AstNode {
public:
    VarNode(typeId type, char *identifier, AstNode *exp, AstNode *scope);
    typeId type;
    char *identifier;
    ExpressionNode *rExp;
    AstNode *scope;
    void evaluate();
};


class VarDeclarationNode: public AstNode {
public:
    VarDeclarationNode(typeId type, char *identifier, AstNode *scope);
    typeId type;
    char *identifier;
    AstNode *scope;
    void evaluate();
};

class VarAssignmentNode: public AstNode {
public:
    VarAssignmentNode(char *identifier, AstNode *exp, AstNode *scope);
    char *identifier;
    ExpressionNode *rExp;
    AstNode *scope;
    void evaluate();
};

class IfNode: public AstNode {
public:
    AstNode *elseBlock;
    void evaluate();
};


class FnNode: public AstNode {
public:
    FnNode(typeId type, char *identifier, AstNode *scope);
    typeId type;
    char *identifier;
    AstNode *scope;
    Value *value;
    void evaluate();
    AstNode *run(AstNode *returnNode);
};


class ReturnNode: public AstNode {
public:
    void evaluate();
    Value *value;
    AstNode *scope;
    AstNode *rNode;
    ReturnNode(AstNode *scope);
    AstNode *getNext();
};

Value *getFromValueStore(AstNode *scope, char* ident);
AstNode *getValueScope(AstNode *scope, char* ident);
