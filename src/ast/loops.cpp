#include <string.h>
#include "ast.h"

void recursion(ExpressionNode *condition, AstNode *body) {
    condition->evaluate();
    if (condition->value->boolValue) {
      body->evaluate();
      /// recursion(condition, body);
    }
};

AstNode* WhileNode::evaluate() {
    ExpressionNode *condition = (ExpressionNode*)this->condition;
    recursion(condition, this->childListHead);
    return this->getNext();
};
