#include <string.h>
#include "ast.h"
#include "exceptions.h"
#include "value.h"

int maxId = 0;

AstNode::AstNode() {
    this->id = maxId;
    this->valueStore = new ValueStore();
    maxId++;
};


AstNode* AstNode::evaluate() {
    ExpressionNode *cur = (ExpressionNode*)this->childListHead;
    while (cur != NULL) {
        cur->evaluate();
        cur = (ExpressionNode*)cur->next;
    }
    return cur;
}


ActParamNode::ActParamNode() {
    this->id = maxId;
    maxId++;
}


AstNode* ActParamNode::evaluate() {
    return this;
}


PrintNode::PrintNode(AstNode *paramsHead) {
    this->childListHead = paramsHead;
    this->id = maxId;
    maxId++;
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
    this->id = maxId;
    this->scope = scope;
    maxId++;
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

void AstNode::addToChildList(AstNode *newNode) {
    newNode->parent = this;
    if (this->childListHead == NULL) {
        this->childListHead = newNode;
    }
    else {
        AstNode *current = this->childListHead;
        while (current->next != NULL) {
            current = current->next;
        }
        current->next = newNode;
    }
};


ConstNode::ConstNode(typeId type, char *identifier, Value *value) {
    if (value->type != type) {
        throw (TypeError("Types did not match"));
    }

    this->id = maxId;
    maxId++;
    this->identifier = identifier;
    this->value = value;
};


AstNode* ConstNode::evaluate() {
    if (constGlobal->values.find(this->identifier) != constGlobal->values.end()) {
        throw (ConstError());
    }
    constGlobal->values[this->identifier] = this->value;
    return this;
};


VarNode::VarNode(typeId type, char *identifier, Value *value, AstNode *scope) {
    if (value->type != type) {
        throw (TypeError("Types did not match"));
    }

    this->id = maxId;
    maxId++;
    this->scope = scope;
    this->identifier = identifier;
    this->value = value;
};


AstNode* VarNode::evaluate() {
    if (constGlobal->values.find(this->identifier) != constGlobal->values.end()) {
        throw (ConstError());
    }
    this->scope->valueStore->set(this->identifier, this->value);
    return this;
};


ExpressionNode* ExpressionNode::run() {
    ExpressionNode *cur = (ExpressionNode*)this->childListHead;
    while (cur != NULL) {
        Value& lVal = *this->value;
        Value *rVal = cur->value;
        if (this->value->type == IDENTIFIER) {
            // lVal = *constGlobal->values[this->value->identValue];
            lVal = *getFromValueStore(this->scope, this->value->identValue);
            //lVal = *this->scope->valueStore->get(this->value->identValue);
        }

        if (cur->value->type == IDENTIFIER) {
            // rVal = constGlobal->values[cur->value->identValue];
            rVal = getFromValueStore(this->scope, cur->value->identValue);
        }

        if (cur->op == NULL) {
            return this;
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

        cur = (ExpressionNode*)cur->next;
    }
    return this;
};


Value *getFromValueStore(AstNode *scope, char* ident) {
    if (constGlobal->values[ident] != NULL) {
        return constGlobal->values[ident];
    }
    Value *val = scope->valueStore->values[ident];
    scope = scope->parent;
    while (val == 0 and scope != NULL) {
        val = scope->valueStore->values[ident];
        scope = scope->parent;
    }
    if (!val) {
        throw UnknownIdentifierError();
    }
    return val;
};
