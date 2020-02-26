#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"

int maxId = 0;

AstNode::AstNode() {
    this->id = maxId;
    maxId++;
    this->valueStore = new ValueStore();
    this->value = new Value();  // evaluated value in case of expressions
};


AstNode* AstNode::evaluate() {
    AstNode *cur = this->childListHead;
    while (cur != NULL) {
        cur = cur->evaluate();
    }
    return this->getNext();
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


AstNode *AstNode::getNext() {
    return this->next;
};

Value *getVariableFromValueStore(AstNode *scope, char *ident) {
    Value *val = scope->valueStore->values[ident];
    while (val == NULL and scope != NULL) {
        val = scope->valueStore->values[ident];
        scope = scope->parent;
    }
    return val;
}


Value *getFromValueStore(AstNode *scope, char *ident) {
    Value *constant = getConstant(ident);
    if (constant) {
        return constant;
    }
    Value *val = getVariableFromValueStore(scope, ident);
    if (!val) {
        throw UnknownIdentifierError(ident);
    }
    if (!val->assigned) {
        throw UnassignedIdentifierError(ident);
    }
    return val;
};


AstNode *getValueScope(AstNode *scope, char* ident) {
    if (scope->valueStore->values[ident]) {
        return scope;
    }
    else {
        if (scope->parent != NULL) {
            return getValueScope(scope->parent, ident);
        }
        else {
            throw UnknownIdentifierError(ident);
        }
    }
};
