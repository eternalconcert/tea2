#include <string.h>
#include "ast.h"


void IfNode::evaluate() {
    ExpressionNode *condition = (ExpressionNode*)this->childListHead;
    condition->evaluate();
    if (condition->value->boolValue) {
        this->childListHead->next->evaluate();
    }
    else if (this->elseBlock != NULL) {
        elseBlock->evaluate();
    }
};
