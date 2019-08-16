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


void VarNode::evaluate() {
    this->rExp->evaluate();
    Value *val = this->rExp->value;

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
};


VarDeclarationNode::VarDeclarationNode(typeId type, char *identifier, AstNode *scope) {
    this->type = type;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};


void VarDeclarationNode::evaluate() {
    if (constGlobal->values.find(this->identifier) != constGlobal->values.end()) {
        throw (ConstError(this->identifier));
    }
    Value *val = new Value();
    val->set(this->type);
    this->scope->valueStore->set(this->identifier, val);
};


VarAssignmentNode::VarAssignmentNode(char *identifier, AstNode *exp, AstNode *scope) {
    this->rExp = (ExpressionNode*)exp;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};


void VarAssignmentNode::evaluate() {
    this->rExp->evaluate();
    Value *val = this->rExp->value;

    AstNode *valScope = getValueScope(this->scope, this->identifier);

    typeId ownType = valScope->valueStore->get(this->identifier)->type;

    if (val->type != ownType) {
        throw (TypeError("Types did not match"));
    }

    valScope->valueStore->set(this->identifier, val);
};
