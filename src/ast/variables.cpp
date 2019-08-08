#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"


VarNode::VarNode(typeId type, char *identifier, Value *value, AstNode *scope) {
    if (value->type != type) {
        throw (TypeError("Types did not match"));
    }
    this->scope = scope;
    this->identifier = identifier;
    this->value = value;
    AstNode();
};


AstNode* VarNode::evaluate() {
    if (constGlobal->values.find(this->identifier) != constGlobal->values.end()) {
        throw (ConstError(this->identifier));
    }
    this->scope->valueStore->set(this->identifier, this->value);
    return this;
};


VarAssignmentNode::VarAssignmentNode(char *identifier, Value *value, AstNode *scope) {
    this->scope = scope;
    this->identifier = identifier;
    this->value = value;
    AstNode();
};

AstNode* VarAssignmentNode::evaluate() {
    AstNode *valScope = getValueScope(this->scope, this->identifier);
    valScope->valueStore->set(this->identifier, this->value);
    return this;
};
