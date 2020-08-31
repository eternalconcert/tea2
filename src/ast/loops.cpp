#include <string.h>
#include "ast.h"

void recursion(ExpressionNode *condition, AstNode *body) {
    ExpressionNode *copy = new ExpressionNode(condition->scope);
    copy->value->type = condition->value->type;
    copy->value->identValue = condition->value->identValue;

    condition->evaluate();
    if (condition->value->boolValue) {
      body->evaluate();
      delete(condition);
      recursion(copy, body);
    }
};

AstNode* WhileNode::evaluate() {
    ExpressionNode *condition = (ExpressionNode*)this->condition;
    recursion(condition, this->childListHead);
    return this->getNext();
};
