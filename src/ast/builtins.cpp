#include <string.h>
#include <fstream>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"
#include "../utils/utils.h"


PrintNode::PrintNode(AstNode *paramsHead, AstNode *scope) {
    this->scope = scope;
    this->paramsHead = paramsHead;
    AstNode();
}


AstNode* PrintNode::evaluate() {
    AstNode *cur = this->paramsHead;
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
};


SystemNode::SystemNode(int index, AstNode *scope) {
    this->scope = scope;
    this->index = index;
    AstNode();
}


AstNode* SystemNode::evaluate() {
    System *sys = System::getSystem();
    if (sys->argc <= this->index) {
        throw SystemError("Too less system args");
    } else {
        this->value->set(sys->args[this->index]);
        fflush(stdout);
    }
    return this->getNext();
};


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


std::string ReadFileNode::readFile(std::string path) {
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
    std::string fromFile;
    switch (this->pathValue->type) {
        case STR:
            fromFile = this->readFile(this->pathValue->stringValue);
            break;
        case IDENTIFIER:
           Value *val = getFromValueStore(this->scope, this->pathValue->identValue);
           if (val->getTrueType() != STR) {
               throw (TypeError("Wrong type for read function"));
           }
           fromFile = this->readFile(val->stringValue);
           break;
    }
    char* cStr = new char[sizeof(fromFile)];
    strcpy(cStr, fromFile.c_str());
    this->value->set(cStr);
    return this->getNext();
};

AssertNode::AssertNode(AstNode *paramsHead, AstNode *scope) {
    this->scope = scope;
    this->paramsHead = paramsHead;
    AstNode();
}


AstNode* AssertNode::evaluate() {
    AstNode *cur = this->paramsHead;
    AstNode *prev = NULL;
    while (cur != NULL) {
        ExpressionNode *eval = (ExpressionNode*)cur;
        eval->evaluate();
        if (prev) {
            Value& lVal = *eval->value;
            Value *rVal = prev->value;
            if (operator!=(lVal, rVal)->boolValue) {
                throw AssertionError(prev->value, eval->value);
            }
        }
        prev = eval;
        cur = cur->getNext();
    }
    return this->getNext();
};


CmdNode::CmdNode(Value *shValue, AstNode *scope) {
    this->shValue = shValue;
    this->scope = scope;
    AstNode();
};


AstNode* CmdNode::evaluate() {
    std::string result;
    switch (this->shValue->type) {
        case STR:
            result = exec(shValue->stringValue);
            break;
        case IDENTIFIER:
            Value *val = getFromValueStore(this->scope, this->shValue->identValue);
            if (val->getTrueType() != STR) {
                throw (TypeError("Wrong type for cmd function"));
            }
            result = exec(val->stringValue);
            break;
    }
    char* cStr = new char[sizeof(result)];
    strcpy(cStr, result.c_str());
    this->value->set(cStr);
    return this->getNext();
};