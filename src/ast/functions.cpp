#include <iostream>
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


// Hilfsfunktion: findet rekursiv den ReturnNode in einem AstNode
AstNode* findReturnNode(AstNode* node) {
    if (!node) return nullptr;

    if (node->statementType == RETURN) return node;

    AstNode* child = node->childListHead;
    while (child) {
        AstNode* found = findReturnNode(child);
        if (found) return found;
        child = child->getNext();
    }
    return nullptr;
}

AstNode* FnCallNode::evaluate() {
    // Funktion aus dem ValueStore holen
    Value *val = getFromValueStore(this->scope, this->identifier, this->location);
    FnDeclarationNode *body = val->functionBody;

    // formale Parameter evaluieren
    VarDeclarationNode *formalParam = (VarDeclarationNode*)body->paramsHead;
    AstNode *actualParam = this->paramsHead;
    while (formalParam != NULL && formalParam->type != UNDEFINED) {
        if (actualParam == NULL) {
            throw ParameterError("Not enough arguments supplied");
        }

        formalParam->evaluate();
        ExpressionNode *eval = (ExpressionNode*)actualParam;
        eval->evaluate();

        if (formalParam->type != eval->value->type) {
            throw TypeError("Argument types does not match", this->location);
        }

        eval->value->set(formalParam->type, this->location);
        eval->value->assigned = true;
        this->scope->valueStore->set(formalParam->identifier, eval->value);

        formalParam = (VarDeclarationNode*)formalParam->getNext();
        actualParam = actualParam->getNext();
    }

    // Funktionskörper ausführen
    AstNode* stmt = body->childListHead;
    while (stmt) {
        stmt->evaluate();

        // Rekursiv nach ReturnNode suchen
        AstNode* retNode = findReturnNode(stmt);
        if (retNode) {
            this->value = ((ReturnNode*)retNode)->value;
            break;  // Funktion sofort beenden
        }

        stmt = stmt->getNext();
    }

    return this->getNext();
}



ReturnNode::ReturnNode(AstNode *scope) : AstNode() {
    this->scope = scope;
    this->statementType = RETURN;  // Direkt hier setzen
};

AstNode* ReturnNode::evaluate() {
    ExpressionNode *result = (ExpressionNode*)this->childListHead;
    result->evaluate();
    this->value = result->value;

    // RETURN explizit setzen
    this->statementType = RETURN;

    return this->getNext();
}
