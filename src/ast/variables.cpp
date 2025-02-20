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
    this->rExp->evaluate();
    Value *val = this->rExp->value;

    if (val->type == IDENTIFIER) {
        val = getFromValueStore(this->scope, val->identValue, this->location);
    }
    if (val->type != this->type) {
        throw (TypeError("Types did not match", this->location));
    }

    this->scope->valueStore->set(this->identifier, val);
    return this->getNext();
};


VarDeclarationNode::VarDeclarationNode(typeId type, char *identifier, AstNode *scope) {
    this->type = type;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};


AstNode* VarDeclarationNode::evaluate() {
    Value *val = new Value();
    val->set(this->type, this->location);
    this->scope->valueStore->set(this->identifier, val);
    return this->getNext();
};


VarAssignmentNode::VarAssignmentNode(char *identifier, AstNode *exp, AstNode *scope) {
    this->rExp = (ExpressionNode*)exp;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};


AstNode* VarAssignmentNode::evaluate() {
    this->rExp->evaluate();
    Value *val = this->rExp->value;
    AstNode *valScope = getValueScope(this->scope, this->identifier, this->location);

    typeId ownType = valScope->valueStore->get(this->identifier)->type;

    if (val->type != ownType) {
        throw (TypeError("Types did not match", this->location));
    }
    valScope->valueStore->set(this->identifier, val);
    return this->getNext();
};
