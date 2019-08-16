#include <string.h>
#include "../exceptions.h"
#include "ast.h"


FnNode::FnNode(typeId type, char *identifier, AstNode *scope) {
    this->type = type;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};

void FnNode::evaluate() {
    if (constGlobal->values.find(this->identifier) != constGlobal->values.end()) {
        throw (ConstError(this->identifier));
    }
    Value *val = new Value();
    val->setFn(this->identifier, this->scope, this);
    this->scope->valueStore->set(this->identifier, val);
};


AstNode *FnNode::run(AstNode *returnNode) {
    Value *val = getFromValueStore(this->scope, this->identifier);
    ExpressionNode *result = (ExpressionNode*)val->block->childListHead;
    result->evaluate();
    return this;
};


ReturnNode::ReturnNode(AstNode *scope) {
    this->scope = scope;
};


AstNode *ReturnNode::getNext() {
    printf("%s\n", "TEST");
    return NULL;
};


void ReturnNode::evaluate() {
    ExpressionNode *result = (ExpressionNode*)this->childListHead;
    result->evaluate();
    this->value = result->value;
};

