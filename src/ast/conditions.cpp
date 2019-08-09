#include <string.h>
#include "ast.h"


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
