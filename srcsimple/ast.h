#include <string>


enum nodeType {ROOT, INT, FLOAT, STR, BOOL, DECLARATION, ADD, SUB, MUL, DIV, IDENTIFIER, TYPE};


std::string getNodeTypeName(nodeType type);

class AstNode {
public:
    nodeType type;
    char *value;

    AstNode(nodeType type);
};
