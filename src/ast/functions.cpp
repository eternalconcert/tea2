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
    printf("Das hier ist die falsche Stelle: this->next ist die Expression die das Teil auswertet, also das 1 + 1 in return 1 + 1. Das next der Funktion bleibt davon unberührt.\n");
    printf("Man müsste also evtl. doch überlegen, ob evaluate() nicht bei jedem Aufruf den Nachfolger zurückgibt und von diesem dann wieder evaluate() aufgerufen wird. Dann könnte man prüfen, ob eine ReturnNode gekommen ist.\n");
    printf("Da könnte dann sowas drin sein wie jumpToNode, was per default NULL ist aber bei ReturnNodes die Rücksprungadresse hat.\n");
    return NULL;
};


void ReturnNode::evaluate() {
    ExpressionNode *result = (ExpressionNode*)this->childListHead;
    result->evaluate();
    this->setNext(NULL);
    this->value = result->value;
};

