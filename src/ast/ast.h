#include <string>
#include "../commons.h"
#include "../valuestore.h"
#include "../value.h"
#include "../../y.tab.h"

class AstNode {
public:
    int id;
    AstNode *childListHead;
    AstNode *parent;
    ValueStore *valueStore;
    Value *value;
    YYLTYPE location;
    StmtType statementType;

    void setLocation(YYLTYPE location);
    void addToChildList(AstNode *newNode);
    virtual AstNode* evaluate();
    AstNode *init(int argc, char **args);
    virtual AstNode* getNext();

    AstNode();

private:
    AstNode *next;
};

class PrintNode: public AstNode {
public:
    AstNode *scope;
    AstNode *paramsHead;
    bool newLine;
    AstNode* evaluate();
    PrintNode(AstNode *paramsHead, AstNode *scope, bool newLine);
};

class SystemArgsNode: public AstNode {
public:
    AstNode *scope;
    Value *indexValue;
    AstNode* evaluate();
    SystemArgsNode(Value *indexValue, AstNode *scope);
};

class LastRcNode: public AstNode {
public:
    AstNode* evaluate();
    LastRcNode();
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

class SleepNode: public AstNode {
public:
    Value *seconds;
    AstNode *scope;
    AstNode *evaluate();

    SleepNode(Value *seconds, AstNode *scope);
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

class InputNode: public AstNode {
public:
    Value *pathValue;
    AstNode *scope;

    AstNode* evaluate();
    void readInput();
    InputNode(AstNode *scope);
};


class CastNode: public AstNode {
public:
    AstNode *scope;
    char *identifier;
    typeId typeName;
    AstNode* evaluate();
    CastNode(char *identifier, typeId typeName, AstNode *scope);
};


class ExpressionNode: public AstNode {
public:
    char *op;
    AstNode *scope;

    Value *runFunctionAndGetResult(AstNode *scope);
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

class WhileNode: public AstNode {
public:
    AstNode* condition;
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

Value *getFromValueStore(AstNode *scope, char* ident, YYLTYPE location);
Value *getVariableFromValueStore(AstNode *scope, char *ident);
AstNode *getValueScope(AstNode *scope, char* ident, YYLTYPE location);
