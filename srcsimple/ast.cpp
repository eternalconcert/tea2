#include <string>
#include "ast.h"


int maxId = 0;

std::string getNodeTypeName(nodeType type) {
    switch(type) {
        case ADD:
            return "ADD";
        case SUB:
            return "SUB";
        case MUL:
            return "MUL";
        case DIV:
            return "DIV";
        case INT:
            return "INT";
        case FLOAT:
            return "FLOAT";
        case STR:
            return "STR";
        case BOOL:
            return "BOOL";
    }
};

AstNode::AstNode() {
    this->id = maxId;
    maxId++;

    printf("nodeType: %i\n");
};



void AstNode::addToChildList(AstNode *newNode) {
    newNode->parent = this;
    if (childListHead == NULL) {
        childListHead = newNode;
    }
    else {
        AstNode *current = childListHead;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = newNode;
    }
};
