#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"

int maxId = 0;

AstNode::AstNode() {
    this->id = maxId;
    this->valueStore = new ValueStore();
    maxId++;
};


void AstNode::evaluate() {
    ExpressionNode *cur = (ExpressionNode*)this->childListHead;
    while (cur != NULL) {
        cur->evaluate();
        cur = (ExpressionNode*)cur->getNext();
        // cur = (ExpressionNode*)cur->next;
    }
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


Value *getFromValueStore(AstNode *scope, char* ident) {
    if (constGlobal->values[ident] != NULL) {
        return constGlobal->values[ident];
    }
    Value *val = scope->valueStore->values[ident];
    while (val == NULL and scope != NULL) {
        val = scope->valueStore->values[ident];
        scope = scope->parent;
    }
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
