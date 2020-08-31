#include <string.h>
#include <iostream>
#include <fstream>
#include "ast.h"
#include "../exceptions.h"
#include "../value.h"
#include "../utils/utils.h"
#include "unistd.h"


PrintNode::PrintNode(AstNode *paramsHead, AstNode *scope, bool newLine) {
    this->scope = scope;
    this->newLine = newLine;
    this->paramsHead = paramsHead;
    AstNode();
}

AstNode* PrintNode::evaluate() {
    AstNode *cur = this->paramsHead;

    cur->location = this->location; // Maybe this can help with the other problems. If removed, location will not work on printing identifiers.

    while (cur != NULL) {
        ExpressionNode *eval = (ExpressionNode*)cur;
        eval->evaluate();
        if (eval->value->type != UNDEFINED) {
            eval->value->repr();
        }
        cur = cur->getNext();
    }
    if (this->newLine) {
        printf("\n");
    };
    fflush(stdout);
    return this->getNext();
};


SystemArgsNode::SystemArgsNode(Value *indexValue, AstNode *scope) {
    this->scope = scope;
    this->indexValue = indexValue;
    AstNode();
}


AstNode* SystemArgsNode::evaluate() {
    int idx;
    switch (this->indexValue->type) {
        case INT:
            idx = this->indexValue->intValue;
            break;
        case IDENTIFIER:
            Value *val = getFromValueStore(this->scope, this->indexValue->identValue, this->location);
            if (val->getTrueType() != INT) {
                throw (TypeError("Wrong type for index", this->location));
            }
            idx = val->intValue;
            break;
    }
    System *sys = System::getSystem();
    if (sys->argc <= this->indexValue->intValue) {
        throw SystemError("Too less system args");
    } else {
        this->value->set(sys->args[idx], this->location);
    }
    return this->getNext();
};


LastRcNode::LastRcNode() {
    AstNode();
}


AstNode* LastRcNode::evaluate() {
    System *sys = System::getSystem();
    this->value->set(sys->lastRc, this->location);
    return this->getNext();
};

SleepNode::SleepNode(Value *seconds, AstNode *scope) {
    this->seconds = seconds;
    this->scope = scope;
    AstNode();
};


AstNode* SleepNode::evaluate() {
    switch (this->seconds->type) {
        case FLOAT:
            usleep(this->seconds->floatValue * 1000000);
            break;
        case INT:
            usleep(this->seconds->intValue * 1000000);
            break;
        case IDENTIFIER:
            Value *val = getFromValueStore(this->scope, this->seconds->identValue, this->location);
            if (val->getTrueType() == FLOAT) {
                usleep(val->floatValue * 1000000);
            }  else if (val->getTrueType() == INT) {
                usleep(val->intValue * 1000000);
            } else {
                throw (TypeError("Wrong type for sleep function", this->location));
            }
            break;
    }
    return this->getNext();
};

QuitNode::QuitNode(Value *rcValue, AstNode *scope) {
    this->rcValue = rcValue;
    this->scope = scope;
    AstNode();
};


AstNode* QuitNode::evaluate() {
    int rc;
    switch (this->rcValue->type) {
        case INT:
            rc = this->rcValue->intValue;
            break;
        case IDENTIFIER:
            Value *val = getFromValueStore(this->scope, this->rcValue->identValue, this->location);
            if (val->getTrueType() != INT) {
                throw (TypeError("Wrong type for exit function", this->location));
            }
            rc = val->intValue;
            break;
    }
    exit(rc);
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
        throw FileNotFoundException(path, this->location);
    }

    try {
        std::string content((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
        return content;
    } catch (std::ios_base::failure) {
        throw FileNotFoundException(path, this->location);
    }
};

AstNode* ReadFileNode::evaluate() {
    std::string fromFile;
    switch (this->pathValue->type) {
        case STR:
            fromFile = this->readFile(this->pathValue->stringValue);
            break;
        case IDENTIFIER:
           Value *val = getFromValueStore(this->scope, this->pathValue->identValue, this->location);
           if (val->getTrueType() != STR) {
               throw (TypeError("Wrong type for read function", this->location));
           }
           fromFile = this->readFile(val->stringValue);
           break;
    }
    char* cStr = new char[sizeof(fromFile)];
    strcpy(cStr, fromFile.c_str());
    this->value->set(cStr, this->location);
    return this->getNext();
};

InputNode::InputNode(AstNode *scope) {
    this->scope = scope;
    AstNode();
};


std::string InputNode::readInput() {
    return "TEST";
};

AstNode* InputNode::evaluate() {
    std::string in;
    std::getline(std::cin, in);
    char* cStr = new char[sizeof(in)];
    strcpy(cStr, in.c_str());
    this->value->set(cStr, this->location);
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
                throw AssertionError(prev->value, eval->value, this->location);
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
            Value *val = getFromValueStore(this->scope, this->shValue->identValue, this->location);
            if (val->getTrueType() != STR) {
                throw (TypeError("Wrong type for cmd function", this->location));
            }
            result = exec(val->stringValue);
            break;
    }
    char* cStr = new char[sizeof(result)];
    strcpy(cStr, result.c_str());
    this->value->set(cStr, this->location);
    return this->getNext();
};