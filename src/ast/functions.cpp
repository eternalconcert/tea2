#include <string.h>
#include "../exceptions.h"
#include "ast.h"


FnNode::FnNode(typeId type, char *identifier, AstNode *scope) {
    this->type = type;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};

AstNode *FnNode::evaluate() {
    if (constGlobal->values.find(this->identifier) != constGlobal->values.end()) {
        throw (ConstError(this->identifier));
    }
    Value *val = new Value();
    val->setFn(this->identifier, this->scope, this);
    this->scope->valueStore->set(this->identifier, val);
    printf("%s\n", "da");
    return this;
};


AstNode *FnNode::run() {
    printf("%s\n", "da1");
    printf("%s\n", this->identifier);
    Value *val = getFromValueStore(this->scope, this->identifier);
    val->block->childListHead->evaluate();
    printf("%s\n", "noch da?");
    return this;
};
