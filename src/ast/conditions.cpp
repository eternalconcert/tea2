#include <string.h>
#include "ast.h"


void IfNode::evaluate() {
    ExpressionNode *condition = (ExpressionNode*)this->childListHead;
    condition->evaluate();
    if (condition->value->boolValue) {
        this->childListHead->getNext()->evaluate();
    }
    else if (this->elseBlock != NULL) {
        elseBlock->evaluate();
    }
};
