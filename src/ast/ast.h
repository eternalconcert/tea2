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
    bool exported;

    void setLocation(YYLTYPE location);
    void addToChildList(AstNode *newNode);
    void appendNextSibling(AstNode *newNode);
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

class WriteFileNode: public AstNode {
public:
    AstNode *pathExpression;
    AstNode *contentExpression;
    AstNode *scope;

    AstNode* evaluate();
    WriteFileNode(AstNode *pathExpression, AstNode *contentExpression, AstNode *scope);
};

class ImportNode: public AstNode {
public:
    std::string importPath;
    std::string baseDir;
    AstNode *scope;

    AstNode* evaluate();
    ImportNode(char *importPath, AstNode *scope, std::string baseDir);
};

class SplitNode: public AstNode {
public:
    AstNode *stringExpression;
    AstNode *separatorExpression;
    AstNode *scope;

    AstNode* evaluate();
    SplitNode(AstNode *stringExpression, AstNode *separatorExpression, AstNode *scope);
};

class FindNode: public AstNode {
public:
    AstNode *stringExpression;
    AstNode *patternExpression;
    AstNode *scope;

    AstNode* evaluate();
    FindNode(AstNode *stringExpression, AstNode *patternExpression, AstNode *scope);
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
    AstNode *expr;
    typeId typeName;
    AstNode* evaluate();
    CastNode(AstNode *expr, typeId typeName, AstNode *scope);
};


class ExpressionNode: public AstNode {
public:
    char *op;
    AstNode *scope;
    Value *initialValue;

    Value *runFunctionAndGetResult(AstNode *scope, Value *functionValue);
    AstNode* evaluate();

    ExpressionNode(AstNode *scope);
};

class LenNode: public ExpressionNode {
public:
    AstNode *stringExpression;
    AstNode *scope;

    AstNode* evaluate();
    LenNode(AstNode *stringExpression, AstNode *scope);
};

class KeysNode: public ExpressionNode {
public:
    AstNode *dictExpression;
    AstNode *scope;

    AstNode* evaluate();
    KeysNode(AstNode *dictExpression, AstNode *scope);
};

class ValuesNode: public ExpressionNode {
public:
    AstNode *dictExpression;
    AstNode *scope;

    AstNode* evaluate();
    ValuesNode(AstNode *dictExpression, AstNode *scope);
};

class ArrayLiteralNode: public ExpressionNode {
public:
    AstNode *items;

    AstNode* evaluate();
    ArrayLiteralNode(AstNode *items, AstNode *scope);
};

class DictLiteralNode: public ExpressionNode {
public:
    AstNode *items;

    AstNode* evaluate();
    DictLiteralNode(AstNode *items, AstNode *scope);
};

class ArrayIndexNode: public ExpressionNode {
public:
    char *identifier;
    AstNode *indexExpression;

    AstNode* evaluate();
    ArrayIndexNode(char *identifier, AstNode *indexExpression, AstNode *scope);
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
    bool variadic;
    AstNode *scope;

    AstNode* evaluate();

    VarDeclarationNode(typeId type, char *identifier, AstNode *scope, bool variadic=false);
};

class VarAssignmentNode: public AstNode {
public:
    char *identifier;
    ExpressionNode *rExp;
    AstNode *scope;

    AstNode* evaluate();

    VarAssignmentNode(char *identifier, AstNode *exp, AstNode *scope);
};

class ArrayAssignmentNode: public AstNode {
public:
    char *identifier;
    AstNode *indexExpression;
    AstNode *rExp;
    AstNode *scope;

    AstNode* evaluate();
    ArrayAssignmentNode(char *identifier, AstNode *indexExpression, AstNode *rExp, AstNode *scope);
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

class ForNode: public AstNode {
public:
    AstNode *init;
    AstNode *condition;
    AstNode *post;
    AstNode* evaluate();
};

class BreakNode: public AstNode {
public:
    AstNode* evaluate();
    BreakNode();
};

class ContinueNode: public AstNode {
public:
    AstNode* evaluate();
    ContinueNode();
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

class FnCallNode: public ExpressionNode {
public:
    AstNode *paramsHead;
    char *identifier;
    Value *pendingFnReturn;
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

class ThrowNode: public AstNode {
public:
    char *identifier;
    AstNode *msgExpression;
    AstNode *scope;
    AstNode* evaluate();
    ThrowNode(char *identifier, AstNode *msgExpression, AstNode *scope);
};

enum TeaBCKind { TEA_BC_NONE, TEA_BC_BREAK, TEA_BC_CONTINUE };

TeaBCKind teaFindBreakContinue(AstNode *n);
void teaResetBreakContinueFlags(AstNode *n);

Value *getFromValueStore(AstNode *scope, char* ident, YYLTYPE location);
Value *getVariableFromValueStore(AstNode *scope, char *ident);
AstNode *getValueScope(AstNode *scope, char* ident, YYLTYPE location);
struct TeaImportResolved {
    std::string path;
    bool lowPriorityExports;
};

AstNode *teaFindReturnExecuted(AstNode *node);

AstNode *parseTeaFileIntoScope(std::string path, AstNode *scope);
std::string resolveTeaPath(std::string path, std::string baseDir);
TeaImportResolved resolveTeaImport(std::string path, std::string baseDir);
void setImportedTeaModuleLowPriority(std::string path, bool low);
bool importedTeaModuleHasLowPriorityExports(std::string path);
std::string currentParseDir();
bool isTeaModuleImported(std::string path);
bool beginTeaModuleImport(std::string path);
void finishTeaModuleImport(std::string path);
void markTeaModuleImported(std::string path);
void registerImportedTeaModuleValue(std::string path, std::string ident, Value *value);
void copyImportedTeaModuleValues(std::string path, AstNode *scope);
