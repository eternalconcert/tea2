#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"


VarNode::VarNode(typeId type, char *identifier, AstNode *exp, AstNode *scope) {
    this->type = type;
    this->rExp = (ExpressionNode*)exp;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};


AstNode* VarNode::evaluate() {
    ExpressionNode *evalExp = (ExpressionNode*)this->rExp->evaluate();
    Value *val = evalExp->value;

    if (val->type == IDENTIFIER) {
        val = this->scope->valueStore->get(val->identValue);
    }
    if (val->type != this->type) {
        throw (TypeError("Types did not match"));
    }

    if (constGlobal->values.find(this->identifier) != constGlobal->values.end()) {
        throw (ConstError(this->identifier));
    }
    this->scope->valueStore->set(this->identifier, val);
    return this;
};


VarAssignmentNode::VarAssignmentNode(char *identifier, AstNode *exp, AstNode *scope) {
    this->rExp = (ExpressionNode*)exp;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};

AstNode* VarAssignmentNode::evaluate() {
    ExpressionNode *evalExp = (ExpressionNode*)this->rExp->evaluate();
    Value *val = evalExp->value;

    AstNode *valScope = getValueScope(this->scope, this->identifier);
    valScope->valueStore->set(this->identifier, val);
    return this;
};
