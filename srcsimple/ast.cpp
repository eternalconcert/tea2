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
};


AstNode* AstNode::evaluate() {
    AstNode *cur = this->childListHead;
    while (cur != NULL) {
        cur->evaluate();
        cur = cur->next;
    }
    return cur;
}


ActParamNode::ActParamNode() {
    this->id = maxId;
    maxId++;
}


AstNode* ActParamNode::evaluate() {
    return this;
}


PrintNode::PrintNode(AstNode *paramsHead) {
    this->childListHead = paramsHead;
    this->id = maxId;
    maxId++;
}


AstNode* PrintNode::evaluate() {
    AstNode *cur = this->childListHead->childListHead;
    while (cur != NULL) {
        ActParamNode *eval = (ActParamNode*)cur->evaluate();
        printf("%s", eval->value);
        cur = cur->next;
    }
    printf("\n");
    return this;
}


void AstNode::addToChildList(AstNode *newNode) {
    newNode->parent = this;
    if (this->childListHead == NULL) {
        this->childListHead = newNode;
    }
    else {
        AstNode *current = this->childListHead;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = newNode;
    }
};

