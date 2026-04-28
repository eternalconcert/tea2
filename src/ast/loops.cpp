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

AstNode* ForNode::evaluate() {
    if (this->init != NULL) {
        this->init->evaluate();
    }

    ExpressionNode *condition = (ExpressionNode*)this->condition;
    bool hasCondition = (condition != NULL);
    if (hasCondition) {
        condition->evaluate();
    }

    while (!hasCondition || condition->value->boolValue) {
        if (this->childListHead != NULL) {
            this->childListHead->evaluate();
        }

        if (this->post != NULL) {
            this->post->evaluate();
        }

        if (hasCondition) {
            condition->evaluate();
        }
    }

    return this->getNext();
};
