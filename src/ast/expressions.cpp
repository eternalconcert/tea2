#include <string.h>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"

ExpressionNode::ExpressionNode(AstNode *scope) {
    AstNode();
    this->scope = scope;
    this->op = NULL;
    this->initialValue = NULL;
};

ArrayLiteralNode::ArrayLiteralNode(AstNode *items, AstNode *scope) : ExpressionNode(scope) {
    this->items = items;
};

AstNode* ArrayLiteralNode::evaluate() {
    std::vector<Value*> values;
    AstNode *cur = this->items->childListHead;

    while (cur != NULL) {
        ExpressionNode *eval = (ExpressionNode*)cur;
        eval->evaluate();
        values.push_back(new Value(*eval->value));
        cur = cur->getNext();
    }

    this->value->set(values, this->location);
    if (this->childListHead != NULL && this->childListHead != this) {
        this->initialValue = new Value(*this->value);
        return ExpressionNode::evaluate();
    }
    return this->getNext();
};

ArrayIndexNode::ArrayIndexNode(char *identifier, AstNode *indexExpression, AstNode *scope) : ExpressionNode(scope) {
    this->identifier = identifier;
    this->indexExpression = indexExpression;
};

AstNode* ArrayIndexNode::evaluate() {
    Value *indexedValue = getFromValueStore(this->scope, this->identifier, this->location);

    ExpressionNode *indexEval = (ExpressionNode*)this->indexExpression;
    indexEval->evaluate();
    Value *indexValue = indexEval->value;
    if (indexValue->type == IDENTIFIER) {
        indexValue = getFromValueStore(this->scope, indexValue->identValue, this->location);
    }

    if (indexValue->getTrueType() != INT) {
        throw TypeError("Index must be an int", this->location);
    }

    int index = indexValue->intValue;

    if (indexedValue->getTrueType() == ARRAY) {
        if (index < 0 || index >= indexedValue->arrayValue.size()) {
            throw TypeError("Array index out of range", this->location);
        }

        this->value = new Value(*indexedValue->arrayValue[index]);
        if (this->childListHead != NULL && this->childListHead != this) {
            this->initialValue = new Value(*this->value);
            return ExpressionNode::evaluate();
        }
        return this->getNext();
    }

    if (indexedValue->getTrueType() == STR) {
        if (index < 0 || index >= strlen(indexedValue->stringValue)) {
            throw TypeError("String index out of range", this->location);
        }

        char *character = new char[2];
        character[0] = indexedValue->stringValue[index];
        character[1] = '\0';
        this->value->set(character, this->location);
        if (this->childListHead != NULL && this->childListHead != this) {
            this->initialValue = new Value(*this->value);
            return ExpressionNode::evaluate();
        }
        return this->getNext();
    }

    throw TypeError("Index access is only implemented for arrays and strings", this->location);
};


Value *ExpressionNode::runFunctionAndGetResult(AstNode *scope, Value *functionValue) {
    Value *startValue = getFromValueStore(scope, functionValue->identValue, this->location);
    FnCallNode *functionBlock = (FnCallNode*)startValue->functionBody;
    // From here
    functionBlock->evaluate();
    return functionBlock->value;
}


Value *resolveExpressionValue(ExpressionNode *expression, Value *value) {
    if (value->type == IDENTIFIER) {
        return getFromValueStore(expression->scope, value->identValue, expression->location);
    }
    if (value->type == FUNCTIONCALL) {
        return expression->runFunctionAndGetResult(expression->scope, value);
    }
    return value;
}


AstNode* ExpressionNode::evaluate() {
    if (this->initialValue == NULL) {
        this->initialValue = new Value(*this->value);
    }

    ExpressionNode *cur = (ExpressionNode*)this->childListHead;
    Value lVal = *resolveExpressionValue(this, this->initialValue);

    if (cur == NULL) {
        this->value = new Value(lVal);
        return this->getNext();
    }

    while (cur != NULL) {
        if (cur == this) {
            this->value = new Value(lVal);
            return this->getNext();
        }

        Value *rVal;
        if (dynamic_cast<ArrayIndexNode*>(cur) != NULL || dynamic_cast<ArrayLiteralNode*>(cur) != NULL || dynamic_cast<LenNode*>(cur) != NULL) {
            cur->evaluate();
            rVal = cur->value;
        } else {
            if (cur->initialValue == NULL) {
                cur->initialValue = new Value(*cur->value);
            }
            rVal = resolveExpressionValue(cur, cur->initialValue);
        }

        if (cur->op == NULL) {
            this->value = new Value(lVal);
            return this->getNext();
        }

        if (!strcmp(cur->op, "+")) {
            this->value = lVal + rVal;
        }

        if (!strcmp(cur->op, "-")) {
            this->value = lVal - rVal;
        }

        if (!strcmp(cur->op, "*")) {
            this->value = lVal * rVal;
        }

        if (!strcmp(cur->op, "/")) {
            this->value = lVal / rVal;
        }

        if (!strcmp(cur->op, "%")) {
            this->value = lVal % rVal;
        }

        if (!strcmp(cur->op, "==")) {
            this->value = lVal == rVal;
        }

        if (!strcmp(cur->op, "!=")) {
            this->value = lVal != rVal;
        }

        if (!strcmp(cur->op, ">")) {
            this->value = lVal > rVal;
        }

        if (!strcmp(cur->op, "<")) {
            this->value = lVal < rVal;
        }

        if (!strcmp(cur->op, ">=")) {
            this->value = lVal >= rVal;
        }

        if (!strcmp(cur->op, "<=")) {
            this->value = lVal <= rVal;
        }

        if (!strcmp(cur->op, "and") || !strcmp(cur->op, "&") || !strcmp(cur->op, "&&")) {
            this->value = lVal && rVal;
        }

        if (!strcmp(cur->op, "or") || !strcmp(cur->op, "|") || !strcmp(cur->op, "||")) {
            this->value = lVal || rVal;
        }

        lVal = *this->value;
        cur = (ExpressionNode*)cur->getNext();
    }
    return this->getNext();
};
