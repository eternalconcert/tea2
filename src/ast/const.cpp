#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"


ConstNode::ConstNode(typeId type, char *identifier, AstNode *expNode) {
    if (expNode->value->type != type) {
        throw (TypeError("Types did not match"));
    }
    AstNode();

    this->identifier = identifier;
    this->value = expNode->value;
};


AstNode* ConstNode::evaluate() {
    ValueStore *constGlobal = ValueStore::getConstGlobalStore();
    if (constGlobal->values.find(this->identifier) != constGlobal->values.end()) {
        throw (ConstError(this->identifier));
    }
    constGlobal->values[this->identifier] = this->value;
    return this->getNext();
};
