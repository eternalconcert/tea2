#include <string.h>
#include "../exceptions.h"
#include "ast.h"


FnDeclarationNode::FnDeclarationNode(typeId type, char *identifier, AstNode *paramsHead, AstNode *scope) {
    this->type = type;
    this->scope = scope;
    this->identifier = identifier;
    this->paramsHead = paramsHead;
    AstNode();
};

AstNode* FnDeclarationNode::evaluate() {
    Value *val = new Value();
    val->setFn(this->identifier, this->scope, this, this->location);
    this->scope->valueStore->set(this->identifier, val);
    return this->getNext();
};


FnCallNode::FnCallNode(char *identifier, AstNode *paramsHead, AstNode *scope) {
    this->scope = scope;
    this->identifier = identifier;
    this->paramsHead = paramsHead;
    AstNode();
}


AstNode* FnCallNode::evaluate() {
    // Getting original function body and evaluating formal params
    Value *val = getFromValueStore(this->scope, this->identifier, this->location);
    FnDeclarationNode *body = val->functionBody;
    VarDeclarationNode *formalParam = (VarDeclarationNode*)body->paramsHead;

    AstNode *actualParam = this->paramsHead;


    while (formalParam != NULL) {
        if (actualParam == NULL) {
            throw ParameterError("Not enough arguments supplied");
        }

        if (formalParam->type > 10) { // Hack!
            formalParam = NULL;
        } else {
            formalParam->evaluate();
            ExpressionNode *eval = (ExpressionNode*)actualParam;
            eval->evaluate();


            if (formalParam->type != eval->value->type) {
                throw TypeError("Argument types does not match", this->location);
            }

            // formalParam->value = eval->value;

            eval->value->set(formalParam->type, this->location);
            eval->value->assigned = true;
            this->scope->valueStore->set(formalParam->identifier, eval->value);
            formalParam = (VarDeclarationNode*)formalParam->getNext();
            actualParam = actualParam->getNext();
        }


    }
    ExpressionNode *functionBody = (ExpressionNode*)val->functionBody->childListHead;
    functionBody->evaluate();
    // Some day, this will work... To test:
    // Value *result = new Value;
    // result->set(23235);
    // this->value = result;
    // -> 02.03.2020, 23:23 It works!
    return this->getNext();

};


ReturnNode::ReturnNode(AstNode *scope) {
    this->scope = scope;
    AstNode();
};


AstNode* ReturnNode::evaluate() {
    ExpressionNode *result = (ExpressionNode*)this->childListHead;
    result->evaluate();
    this->value = result->value;
    return this->getNext();
};
