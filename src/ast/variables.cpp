#include <string.h>
#include <string>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"


VarNode::VarNode(typeId type, char *identifier, AstNode *exp, AstNode *scope) {
    this->type = type;
    this->rExp = (ExpressionNode*)exp;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};


AstNode* VarNode::evaluate() {
    this->rExp->evaluate();
    Value *val = this->rExp->value;

    if (val->type == IDENTIFIER) {
        val = getFromValueStore(this->scope, val->identValue, this->location);
    }
    if (val->type != this->type) {
        throw (TypeError("Types did not match", this->location));
    }

    this->scope->valueStore->set(this->identifier, copyValueDeep(val));
    return this->getNext();
};


VarDeclarationNode::VarDeclarationNode(typeId type, char *identifier, AstNode *scope) {
    this->type = type;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};


AstNode* VarDeclarationNode::evaluate() {
    Value *val = new Value();
    val->set(this->type, this->location);
    this->scope->valueStore->set(this->identifier, val);
    return this->getNext();
};


VarAssignmentNode::VarAssignmentNode(char *identifier, AstNode *exp, AstNode *scope) {
    this->rExp = (ExpressionNode*)exp;
    this->scope = scope;
    this->identifier = identifier;
    AstNode();
};


AstNode* VarAssignmentNode::evaluate() {
    this->rExp->evaluate();
    Value *val = this->rExp->value;
    AstNode *valScope = getValueScope(this->scope, this->identifier, this->location);

    typeId ownType = valScope->valueStore->get(this->identifier)->type;

    if (val->type != ownType) {
        throw (TypeError("Types did not match", this->location));
    }
    valScope->valueStore->set(this->identifier, copyValueDeep(val));
    return this->getNext();
};

ArrayAssignmentNode::ArrayAssignmentNode(char *identifier, AstNode *indexExpression, AstNode *rExp, AstNode *scope) {
    this->identifier = identifier;
    this->indexExpression = indexExpression;
    this->rExp = rExp;
    this->scope = scope;
    AstNode();
};

AstNode* ArrayAssignmentNode::evaluate() {
    ExpressionNode *indexEval = (ExpressionNode*)this->indexExpression;
    indexEval->evaluate();
    Value *indexValue = indexEval->value;
    if (indexValue->type == IDENTIFIER) {
        indexValue = getFromValueStore(this->scope, indexValue->identValue, this->location);
    }

    Value *lhsVal = getFromValueStore(this->scope, this->identifier, this->location);

    ExpressionNode *rhsEval = (ExpressionNode*)this->rExp;
    rhsEval->evaluate();
    Value *rhsVal = rhsEval->value;
    if (rhsVal->type == IDENTIFIER) {
        rhsVal = getFromValueStore(this->scope, rhsVal->identValue, this->location);
    }

    if (lhsVal->getTrueType() == DICT) {
        std::string key;
        switch (indexValue->getTrueType()) {
            case STR:
                key = indexValue->stringValue;
                break;
            case INT:
                key = std::to_string(indexValue->intValue);
                break;
            case FLOAT:
                key = std::to_string(indexValue->floatValue);
                break;
            case BOOL:
                key = indexValue->boolValue ? "true" : "false";
                break;
            default:
                throw TypeError("Dictionary index must be string, int, float or bool", this->location);
        }
        lhsVal->dictValue[key] = new Value(*rhsVal);
        return this->getNext();
    }

    if (indexValue->getTrueType() != INT) {
        throw TypeError("Array index must be an int", this->location);
    }

    int index = indexValue->intValue;
    if (index < 0) {
        throw TypeError("Array index out of range", this->location);
    }

    if (lhsVal->getTrueType() != ARRAY) {
        throw TypeError("Left side of array assignment must be an array", this->location);
    }

    while (lhsVal->arrayValue.size() <= (size_t)index) {
        lhsVal->arrayValue.push_back(new Value());
    }

    lhsVal->arrayValue[index] = new Value(*rhsVal);
    return this->getNext();
};
