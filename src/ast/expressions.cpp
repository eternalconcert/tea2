#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"

ExpressionNode::ExpressionNode(AstNode *scope) {
    AstNode();
    this->scope = scope;
};

AstNode* ExpressionNode::evaluate() {
    this->run();
    return this;
};

ExpressionNode* ExpressionNode::run() {
    ExpressionNode *cur = (ExpressionNode*)this->childListHead;
    while (cur != NULL) {
        Value& lVal = *this->value;
        Value *rVal = cur->value;
        if (this->value->type == IDENTIFIER) {
            // lVal = *constGlobal->values[this->value->identValue];
            lVal = *getFromValueStore(this->scope, this->value->identValue);
            //lVal = *this->scope->valueStore->get(this->value->identValue);
        }

        if (cur->value->type == IDENTIFIER) {
            // rVal = constGlobal->values[cur->value->identValue];
            rVal = getFromValueStore(this->scope, cur->value->identValue);
        }

        if (cur->op == NULL) {
            return this;
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

        if (!strcmp(cur->op, "==")) {
            this->value = lVal == rVal;
        }

        if (!strcmp(cur->op, "!=")) {
            this->value = lVal != rVal;
        }

        if (!strcmp(cur->op, ">")) {
            this->value = lVal > rVal;
        }

        if (!strcmp(cur->op, "<")) {
            this->value = lVal < rVal;
        }

        if (!strcmp(cur->op, ">=")) {
            this->value = lVal >= rVal;
        }

        if (!strcmp(cur->op, "<=")) {
            this->value = lVal <= rVal;
        }

        cur = (ExpressionNode*)cur->next;
    }
    return this;
};
