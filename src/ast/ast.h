#include <string>
#include "../commons.h"
#include "../valuestore.h"
#include "../value.h"

class AstNode {
public:
    int id;
    AstNode *childListHead;
    AstNode *parent;
    ValueStore *valueStore;
    Value *value;

    void addToChildList(AstNode *newNode);
    virtual AstNode* evaluate();
    virtual AstNode* getNext();
    void setNext(AstNode *nextNode);

    AstNode();

private:
    AstNode *next;
};

class PrintNode: public AstNode {
public:
    AstNode *scope;
    AstNode *paramsHead;
    AstNode* evaluate();
    PrintNode(AstNode *paramsHead, AstNode *scope);
};

class AssertNode: public AstNode {
public:
  AstNode *scope;
  AstNode *paramsHead;
  AstNode* evaluate();
  AssertNode(AstNode *paramsHead, AstNode *scope);
};

class CmdNode: public AstNode {
public:
    Value *shValue;
    AstNode *scope;

    AstNode* evaluate();

    CmdNode(Value *shValue, AstNode *scope);
};

class QuitNode: public AstNode {
public:
    Value *rcValue;
    AstNode *scope;

    AstNode* evaluate();

    QuitNode(Value *rcValue, AstNode *scope);
};

class ReadFileNode: public AstNode {
public:
    Value *pathValue;
    AstNode *scope;

    AstNode* evaluate();
    std::string readFile(std::string path);
    ReadFileNode(Value *pathValue, AstNode *scope);
};

class ExpressionNode: public AstNode {
public:
    char *op;
    AstNode *scope;

    Value *runFunctionAndGetResult();
    AstNode* evaluate();

    ExpressionNode(AstNode *scope);
};

class VarNode: public AstNode {
public:
    typeId type;
    char *identifier;
    ExpressionNode *rExp;
    AstNode *scope;

    AstNode* evaluate();

    VarNode(typeId type, char *identifier, AstNode *exp, AstNode *scope);
};

class VarDeclarationNode: public AstNode {
public:
    typeId type;
    char *identifier;
    AstNode *scope;

    AstNode* evaluate();

    VarDeclarationNode(typeId type, char *identifier, AstNode *scope);
};

class VarAssignmentNode: public AstNode {
public:
    char *identifier;
    ExpressionNode *rExp;
    AstNode *scope;

    AstNode* evaluate();

    VarAssignmentNode(char *identifier, AstNode *exp, AstNode *scope);
};

class IfNode: public AstNode {
public:
    AstNode *elseBlock;
    AstNode* evaluate();
};

class FnDeclarationNode: public AstNode {
public:
    typeId type;
    char *identifier;
    AstNode *scope;
    AstNode *paramsHead;

    Value *value;

    AstNode* evaluate();

    FnDeclarationNode(typeId type, char *identifier, AstNode *paramsHead, AstNode *scope);
};

class FnCallNode: public AstNode {
public:
    AstNode *scope;
    AstNode *paramsHead;
    char *identifier;
    AstNode* evaluate();
    FnCallNode(char *identifier, AstNode *paramsHead, AstNode *scope);
};

class ReturnNode: public AstNode {
public:
    AstNode* evaluate();
    Value *value;
    AstNode *scope;

    ReturnNode(AstNode *scope);
};

Value *getFromValueStore(AstNode *scope, char* ident);
Value *getVariableFromValueStore(AstNode *scope, char *ident);
AstNode *getValueScope(AstNode *scope, char* ident);
