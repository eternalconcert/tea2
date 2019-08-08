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


AstNode* AstNode::evaluate() {
    ExpressionNode *cur = (ExpressionNode*)this->childListHead;
    while (cur != NULL) {
        cur->evaluate();
        cur = (ExpressionNode*)cur->next;
    }
    return cur;
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


AstNode *IfNode::evaluate() {
    ExpressionNode *condition = (ExpressionNode*)this->childListHead->evaluate();
    if (condition->value->boolValue) {
        this->childListHead->next->evaluate();
    }
    else if (this->elseBlock != NULL) {
        elseBlock->evaluate();
    }
    return this;
};


Value *getFromValueStore(AstNode *scope, char* ident) {
    if (constGlobal->values[ident] != NULL) {
        return constGlobal->values[ident];
    }
    Value *val = scope->valueStore->values[ident];
    scope = scope->parent;
    while (val == 0 and scope != NULL) {
        val = scope->valueStore->values[ident];
        scope = scope->parent;
    }
    if (!val) {
        throw UnknownIdentifierError(ident);
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
