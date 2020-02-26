#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"


ConstNode::ConstNode(typeId type, char *identifier, AstNode *expNode, AstNode *scope) {
    if (expNode->value->type != type) {
        throw (TypeError("Types did not match"));
    }

    this->identifier = identifier;
    this->value = expNode->value;
    this->scope = scope;
    AstNode();
};


AstNode* ConstNode::evaluate() {
    checkConstant(this->identifier);
    Value *val = getVariableFromValueStore(this->scope, this->identifier);
    if (val != NULL) {
        throw ConstError("Identifier already in use as constant");
    }
    scope->valueStore->set(identifier, this->value);

    ValueStore *constGlobal = ValueStore::getConstGlobalStore();
    constGlobal->set(this->identifier, this->value);
    return this->getNext();

};
