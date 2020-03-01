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
    checkConstant(this->identifier);

    AstNode *cur = this->paramsHead;
    while (cur != NULL) {
        cur->evaluate();
        cur = cur->getNext();
    }

    Value *val = new Value();
    val->setFn(this->identifier, this->scope, this);
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
    Value *val = getFromValueStore(this->scope, this->identifier);
    ExpressionNode *result = (ExpressionNode*)val->block->childListHead;
    result->evaluate();
    // Some day, this will work... To test:
    // result->value->set(23235);
    // this->value = result->value;
    return this->getNext();

    // AstNode *cur = this->paramsHead;
    // while (cur != NULL) {
    //     ExpressionNode *eval = (ExpressionNode*)cur;
    //     eval->evaluate();
    //     if (eval->value->type != UNDEFINED) {
    //         eval->value->repr();
    //     }
    //     cur = cur->getNext();
    // }

    // // this->value->set(std::string("I am a value!").c_str());
    // return this->getNext();
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
