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


Value *ExpressionNode::runFunctionAndGetResult() {
    Value *startValue = getFromValueStore(this->scope, this->value->identValue);
    FnNode *eval = (FnNode*)startValue->block;
    // From here
    eval->run(this);
    Value *a = new Value();
    a->set(23);

    return a;
}


ExpressionNode* ExpressionNode::run() {
    ExpressionNode *cur = (ExpressionNode*)this->childListHead;
    if (cur == NULL) {
        if (this->value->type == IDENTIFIER) {
            this->value = getFromValueStore(this->scope, this->value->identValue);
        }
        if (this->value->type == FUNCTIONCALL) {
            this->value = this->runFunctionAndGetResult();
        }

        return this;
    }
    while (cur != NULL) {
        Value& lVal = *this->value;
        Value *rVal = cur->value;
        if (this->value->type == IDENTIFIER) {
            lVal = *getFromValueStore(this->scope, this->value->identValue);
        }

        if (cur->value->type == IDENTIFIER) {
            rVal = getFromValueStore(this->scope, cur->value->identValue);
        }

        if (this->value->type == FUNCTIONCALL) {
            lVal = *this->runFunctionAndGetResult();
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
