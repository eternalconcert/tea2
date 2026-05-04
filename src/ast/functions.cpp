#include <iostream>
#include <stdio.h>
#include <string.h>
#include <utility>
#include <vector>
#include "../exceptions.h"
#include "ast.h"

static thread_local std::vector<FnCallNode*> teaActiveFnCallStack;

static void teaSwapValueStoresRec(
    AstNode *node,
    std::vector<std::pair<AstNode *, ValueStore *>> &saved
) {
    if (!node) return;

    saved.push_back({node, node->valueStore});
    node->valueStore = new ValueStore();

    AstNode *child = node->childListHead;
    while (child) {
        teaSwapValueStoresRec(child, saved);
        child = child->getNext();
    }

    IfNode *ifNode = dynamic_cast<IfNode *>(node);
    if (ifNode != nullptr) {
        teaSwapValueStoresRec(ifNode->elseBlock, saved);
    }
}

static void teaRestoreValueStores(
    std::vector<std::pair<AstNode *, ValueStore *>> &saved
) {
    for (auto it = saved.rbegin(); it != saved.rend(); ++it) {
        AstNode *node = it->first;
        ValueStore *oldStore = it->second;
        ValueStore *tmp = node->valueStore;
        node->valueStore = oldStore;
        delete tmp;
    }
    saved.clear();
}


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


FnCallNode::FnCallNode(char *identifier, AstNode *paramsHead, AstNode *scope)
    : ExpressionNode(scope) {
    this->identifier = identifier;
    this->paramsHead = paramsHead;
    this->pendingFnReturn = nullptr;
}


void resetReturnNodes(AstNode* node) {
    if (!node) return;

    if (dynamic_cast<ReturnNode*>(node) != nullptr) {
        node->statementType = OTHER;
    }

    AstNode* child = node->childListHead;
    while (child) {
        resetReturnNodes(child);
        child = child->getNext();
    }

    IfNode* ifNode = dynamic_cast<IfNode*>(node);
    if (ifNode != nullptr) {
        resetReturnNodes(ifNode->elseBlock);
    }
}


AstNode* FnCallNode::evaluate() {
    Value *val = getFromValueStore(this->scope, this->identifier, this->location);
    FnDeclarationNode *body = val->functionBody;
    AstNode *functionScope = body->childListHead;

    // Aktuelle Argumente zuerst auswerten, solange noch das ValueStore des
    // laufenden Aufrufs aktiv ist (dieselbe Fn teilt functionScope mit dem Aufrufer).
    VarDeclarationNode *formalParam = (VarDeclarationNode*)body->paramsHead;
    AstNode *actualParam = this->paramsHead;
    std::vector<Value *> boundArgs;
    while (formalParam != NULL && formalParam->type != UNDEFINED) {
        // Variadic formal parameter: collect remaining actual params into an array
        if (formalParam->variadic) {
            std::vector<Value*> vargs;
            AstNode *curActual = actualParam;
            while (curActual != NULL) {
                ExpressionNode *eval = (ExpressionNode*)curActual;
                eval->evaluate();
                Value *actualValue = eval->value;
                if (actualValue->type == IDENTIFIER) {
                    actualValue = getFromValueStore(this->scope, actualValue->identValue, this->location);
                }
                vargs.push_back(new Value(*actualValue));
                curActual = curActual->getNext();
            }

            Value *arrayVal = new Value();
            arrayVal->set(vargs, this->location);
            arrayVal->assigned = true;
            // push array as next bound arg (will be assigned after swapping value stores)
            boundArgs.push_back(arrayVal);
            // no more formal params to process
            formalParam = (VarDeclarationNode*)formalParam->getNext();
            actualParam = NULL;
            break;
        }

        if (actualParam == NULL) {
            throw ParameterError("Not enough arguments supplied");
        }

        ExpressionNode *eval = (ExpressionNode*)actualParam;
        eval->evaluate();
        Value *actualValue = eval->value;
        if (actualValue->type == IDENTIFIER) {
            actualValue = getFromValueStore(this->scope, actualValue->identValue, this->location);
        }

        if (formalParam->type != actualValue->type) {
            throw TypeError("Argument types does not match", this->location);
        }

        Value *paramValue = new Value(*actualValue);
        paramValue->assigned = true;
        boundArgs.push_back(paramValue);

        formalParam = (VarDeclarationNode*)formalParam->getNext();
        actualParam = actualParam->getNext();
    }

    std::vector<std::pair<AstNode *, ValueStore *>> savedValueStores;
    teaSwapValueStoresRec(functionScope, savedValueStores);

    formalParam = (VarDeclarationNode*)body->paramsHead;
    for (size_t i = 0; formalParam != NULL && formalParam->type != UNDEFINED; i++) {
        functionScope->valueStore->set(formalParam->identifier, boundArgs[i]);
        formalParam = (VarDeclarationNode*)formalParam->getNext();
    }

    resetReturnNodes(body);
    this->pendingFnReturn = nullptr;
    teaActiveFnCallStack.push_back(this);
    AstNode* stmt = body->childListHead;
    while (stmt) {
        stmt->evaluate();
        if (this->pendingFnReturn != nullptr) {
            this->value = this->pendingFnReturn;
            break;
        }

        stmt = stmt->getNext();
    }
    if (this->pendingFnReturn != nullptr) {
        this->value = this->pendingFnReturn;
    }
    teaActiveFnCallStack.pop_back();

    teaRestoreValueStores(savedValueStores);

    resetReturnNodes(body);

    if (this->childListHead != NULL && this->childListHead != this) {
        this->initialValue = new Value(*this->value);
        return ExpressionNode::evaluate();
    }
    return this->getNext();
}



ReturnNode::ReturnNode(AstNode *scope) : AstNode() {
    this->scope = scope;
};

AstNode* ReturnNode::evaluate() {
    ExpressionNode *result = (ExpressionNode*)this->childListHead;
    result->evaluate();
    this->value = result->value;

    // RETURN explizit setzen
    this->statementType = RETURN;

    if (!teaActiveFnCallStack.empty()) {
        teaActiveFnCallStack.back()->pendingFnReturn = this->value;
    }

    return this->getNext();
}
