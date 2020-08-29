#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"

ExpressionNode::ExpressionNode(AstNode *scope) {
    AstNode();
    this->scope = scope;
};


Value *ExpressionNode::runFunctionAndGetResult() {
    Value *startValue = getFromValueStore(this->scope, this->value->identValue, this->location);
    FnCallNode *functionBlock = (FnCallNode*)startValue->functionBody;
    // From here
    functionBlock->evaluate();
    return functionBlock->value;
}


AstNode* ExpressionNode::evaluate() {
    ExpressionNode *cur = (ExpressionNode*)this->childListHead;
    if (cur == NULL) {
        if (this->value->type == IDENTIFIER) {
            this->value = getFromValueStore(this->scope, this->value->identValue, this->location);
        }
        if (this->value->type == FUNCTIONCALL) {
            this->value = this->runFunctionAndGetResult();
        }

        return this->getNext();
    }

    while (cur != NULL) {
        Value& lVal = *this->value;
        Value *rVal = cur->value;
        if (this->value->type == IDENTIFIER) {
            lVal = *getFromValueStore(this->scope, this->value->identValue, this->location);
        }

        if (cur->value->type == IDENTIFIER) {
            rVal = getFromValueStore(this->scope, cur->value->identValue, this->location);
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

        if (!strcmp(cur->op, "%")) {
            this->value = lVal % rVal;
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

        if (!strcmp(cur->op, "and") || !strcmp(cur->op, "&") || !strcmp(cur->op, "&&")) {
            this->value = lVal && rVal;
        }

        if (!strcmp(cur->op, "or") || !strcmp(cur->op, "|") || !strcmp(cur->op, "||")) {
            this->value = lVal || rVal;
        }

        cur = (ExpressionNode*)cur->getNext();
    }
    return this->getNext();
};
