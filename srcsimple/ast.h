#include <string>


enum nodeType {ROOT, INT, FLOAT, STR, BOOL, DECLARATION, ADD, SUB, MUL, DIV, IDENTIFIER, TYPE};


std::string getNodeTypeName(nodeType type);

class AstNode {
public:
    int id;
    char *value;
    AstNode *childListHead;
    AstNode *next;
    AstNode *parent;
    void addToChildList(AstNode *newNode);

    AstNode();
};


class RootNode: public AstNode {
public:
    void run() {
        printf("Gooooo!\n");
    }
};
