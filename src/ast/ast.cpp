#include <stdio.h>
#include <string.h>
#include <string>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"
#include "../utils/utils.h"

int maxId = 0;

AstNode *teaFindReturnExecuted(AstNode *node) {
    if (!node) {
        return nullptr;
    }
    if (node->statementType == RETURN) {
        return node;
    }
    AstNode *child = node->childListHead;
    while (child) {
        AstNode *found = teaFindReturnExecuted(child);
        if (found) {
            return found;
        }
        child = child->getNext();
    }
    IfNode *ifNode = dynamic_cast<IfNode*>(node);
    if (ifNode != nullptr) {
        return teaFindReturnExecuted(ifNode->elseBlock);
    }
    return nullptr;
}

AstNode::AstNode() {
    this->id = maxId;
    maxId++;
    this->childListHead = NULL;
    this->parent = NULL;
    this->next = NULL;
    this->valueStore = new ValueStore();
    this->value = new Value();  // evaluated value in case of expressions
    this->statementType = OTHER;
    this->exported = false;
};


AstNode* AstNode::init(int argc, char **args) {
    System *sys = System::getSystem();
    sys->setSystem(argc, args);
    return this->evaluate();
}

AstNode* AstNode::evaluate() {
    AstNode *cur = this->childListHead;
    while (cur != NULL) {
        AstNode *after = cur->evaluate();
        if (teaFindReturnExecuted(cur) != nullptr) {
            break;
        }
        cur = after;
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

void AstNode::appendNextSibling(AstNode *newNode) {
    AstNode *cur = this;
    while (cur->next != NULL) {
        cur = cur->next;
    }
    cur->next = newNode;
}


AstNode *AstNode::getNext() {
    return this->next;
};

Value *getVariableFromValueStore(AstNode *scope, char *ident) {
    std::string key(ident);
    while (scope != NULL) {
        auto it = scope->valueStore->values.find(key);
        if (it != scope->valueStore->values.end() && it->second != NULL) {
            return it->second;
        }
        scope = scope->parent;
    }
    return nullptr;
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
    std::string key(ident);
    auto it = scope->valueStore->values.find(key);
    if (it != scope->valueStore->values.end() && it->second != NULL) {
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
