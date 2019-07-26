#include "ast.h"
#include "exceptions.h"
#include "value.h"

int maxId = 0;

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
        eval->value->repr();
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


ConstNode::ConstNode(typeId type, char *identifier, Value *value) {
    if (value->type != type) {
        throw (TypeError());
    }

    this->id = maxId;
    maxId++;
    this->identifier = identifier;
    this->value = value;
};


AstNode* ConstNode::evaluate() {
    if (global->constants.find(this->identifier) != global->constants.end()) {
        throw (ConstError());
    }
    global->constants[this->identifier] = this->value;
    return this;
};
