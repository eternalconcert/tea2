#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"
#include "../utils/utils.h"

int maxId = 0;

AstNode::AstNode() {
    this->id = maxId;
    maxId++;
    this->valueStore = new ValueStore();
    this->value = new Value();  // evaluated value in case of expressions
    this->statementType = OTHER;
};


AstNode* AstNode::init(int argc, char **args) {
    System *sys = System::getSystem();
    sys->setSystem(argc, args);
    return this->evaluate();
}

AstNode* AstNode::evaluate() {
    AstNode *cur = this->childListHead;
    while (cur != NULL) {
        cur = cur->evaluate();
    }
    return this->getNext();
}

void AstNode::setLocation(YYLTYPE location) {
    this->location = location;
};

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


Value *getFromValueStore(AstNode *scope, char *ident, YYLTYPE location) {
    Value *val = getVariableFromValueStore(scope, ident);
    if (!val) {
        throw UnknownIdentifierError(ident, location);
    }
    if (!val->assigned) {
        throw UnassignedIdentifierError(ident, location);
    }
    return val;
};


AstNode *getValueScope(AstNode *scope, char* ident, YYLTYPE location) {
    if (scope->valueStore->values[ident] != NULL) {
        return scope;
    }
    else {
        if (scope->parent != NULL) {
            return getValueScope(scope->parent, ident, location);
        }
        else {
            throw UnknownIdentifierError(ident, location);
        }
    }
};
