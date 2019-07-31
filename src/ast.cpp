#include <string.h>
#include "ast.h"
#include "exceptions.h"
#include "scope.h"
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
        throw (TypeError("Types did not match"));
    }

    this->id = maxId;
    maxId++;
    this->identifier = identifier;
    this->value = value;
};


AstNode* ConstNode::evaluate() {
    if (constGlobal->valueStore.find(this->identifier) != constGlobal->valueStore.end()) {
        throw (ConstError());
    }
    constGlobal->valueStore[this->identifier] = this->value;
    return this;
};


ExpressionNode* ExpressionNode::run(Value *currentResult) {
    if (this->childListHead == NULL and this->op == NULL) {
        this->value = currentResult;
        return this;
    }

    else  { // (this->childListHead != NULL)
            ExpressionNode *cur = (ExpressionNode*)this->childListHead;
            while (cur != NULL) {

                Value& lVal = *this->value;
                Value *rVal = cur->value;

                if (this->value->type == IDENTIFIER) {
                    lVal = *constGlobal->valueStore[this->value->identValue];
                }

                if (cur->value->type == IDENTIFIER) {
                    rVal = constGlobal->valueStore[cur->value->identValue];
                }
                if (!strcmp(cur->op, "+")) {
                    this->value = lVal + rVal;
                }

                if (!strcmp(cur->op, "-")) {
                    this->value = lVal - rVal;
                }

                if (!strcmp(cur->op, "*")) {
                    this->value = lVal * rVal;
                }

                if (!strcmp(cur->op, "/")) {
                    this->value = lVal / rVal;
                }

                cur = (ExpressionNode*)cur->next;
            }
        return this;
    }
};
