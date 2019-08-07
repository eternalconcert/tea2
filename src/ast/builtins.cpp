#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"


PrintNode::PrintNode(AstNode *paramsHead) {
    this->childListHead = paramsHead;
    AstNode();
}


AstNode* PrintNode::evaluate() {
    AstNode *cur = this->childListHead;
    while (cur != NULL) {
        ActParamNode *eval = (ActParamNode*)cur->evaluate();
        eval->value->repr();
        cur = cur->next;
    }
    printf("\n");
    return this;
}

QuitNode::QuitNode(Value *rcValue, AstNode *scope) {
    this->rcValue = rcValue;
    this->scope = scope;
    AstNode();
};


AstNode* QuitNode::evaluate() {
    switch (this->rcValue->type) {
        case INT:
            exit(this->rcValue->intValue);
            break;
        case IDENTIFIER:
            // Value *val = constGlobal->values[this->rcValue->identValue];
            Value *val = this->scope->valueStore->get(this->rcValue->identValue);
            if (val->getTrueType() != INT) {
                throw (TypeError("Wrong type for exit function"));
            }
            exit(val->intValue);
            break;
    }

};
