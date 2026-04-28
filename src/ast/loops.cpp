#include "ast.h"

AstNode* WhileNode::evaluate() {
    ExpressionNode *condition = (ExpressionNode*)this->condition;
    condition->evaluate();

    while (condition->value->boolValue) {
        if (this->childListHead != NULL) {
            this->childListHead->evaluate();
        }
        condition->evaluate();
    }

    return this->getNext();
};
