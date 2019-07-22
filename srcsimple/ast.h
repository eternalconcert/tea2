#include <string>


enum nodeType {ROOT, INT, FLOAT, STR, BOOL, DECLARATION, ADD, SUB, MUL, DIV, IDENTIFIER, TYPE};


std::string getNodeTypeName(nodeType type);

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
    char *value;
    AstNode* evaluate();
    ActParamNode();
};

class PrintNode: public AstNode {
public:
    AstNode* evaluate();
    PrintNode(AstNode *paramsHead);
};


