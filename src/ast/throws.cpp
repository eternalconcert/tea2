#include "ast.h"
#include "../exceptions.h"
#include <string>

ThrowNode::ThrowNode(char *identifier, AstNode *msgExpression, AstNode *scope) {
    this->identifier = identifier;
    this->msgExpression = msgExpression;
    this->scope = scope;
    AstNode();
}

AstNode* ThrowNode::evaluate() {
    ExpressionNode *msgEval = (ExpressionNode*)this->msgExpression;
    msgEval->evaluate();

    Value *msgValue = msgEval->value;
    if (msgValue->type == IDENTIFIER) {
        msgValue = getFromValueStore(this->scope, msgValue->identValue, this->location);
    }

    if (msgValue->getTrueType() != STR) {
        throw TypeError("Throw message must be a string", this->location);
    }

    throw BaseError(std::string(this->identifier) + ": " + std::string(msgValue->stringValue), this->location);
    return this->getNext();
};
