#include <string.h>
#include <fstream>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"


PrintNode::PrintNode(AstNode *paramsHead, AstNode *scope) {
    this->scope = scope;
    this->childListHead = paramsHead;
    AstNode();
}


AstNode* PrintNode::evaluate() {
    AstNode *cur = this->childListHead;
    while (cur != NULL) {
        ExpressionNode *eval = (ExpressionNode*)cur;
        eval->evaluate();
        if (eval->value->type != UNDEFINED) {
            eval->value->repr();
        }
        cur = cur->getNext();
    }
    printf("\n");
    fflush(stdout);
    return this->getNext();
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
            Value *val = getFromValueStore(this->scope, this->rcValue->identValue);
            if (val->getTrueType() != INT) {
                throw (TypeError("Wrong type for exit function"));
            }
            exit(val->intValue);
            break;
    }
    return this->getNext();
};



ReadFileNode::ReadFileNode(Value *pathValue, AstNode *scope) {
    this->pathValue = pathValue;
    this->scope = scope;
    AstNode();
};


std::string ReadFileNode::read(std::string path) {
    std::ifstream file(path);

    if (!file) {
        throw FileNotFoundException(path);
    }

    try {
        std::string content((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
        return content;
    } catch (std::ios_base::failure) {
        throw FileNotFoundException(path);
    }
};


AstNode* ReadFileNode::evaluate() {
    switch (this->pathValue->type) {
        case STR:
            printf("%s\n", this->read(this->pathValue->stringValue).c_str());
            break;
        case IDENTIFIER:
            Value *val = getFromValueStore(this->scope, this->pathValue->identValue);
            if (val->getTrueType() != STR) {
                throw (TypeError("Wrong type readFile function"));
            }
            printf("%s\n", this->read(val->stringValue).c_str());
            break;
    }
    return this->getNext();
};
