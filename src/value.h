#ifndef VALUE_H
#define VALUE_H
#include <map>
#include <string>
#include "commons.h"

class AstNode;


class Value {
public:
    AstNode *scope;
    typeId type;
    typeId getTrueType();
    int intValue;
    float floatValue;
    char *stringValue;
    bool boolValue;
    char *identValue;
    bool assigned = true;
    AstNode *block;

    void set(typeId type);  // Set empty
    void set(char *value);
    void set(int value);
    void set(float value);
    void set(bool value);
    void setIdent(char *value, AstNode *scope);
    void setFn(char *value, AstNode *scope, AstNode *block);
    void setFnCall(char *value, AstNode *scope);
    void repr();
};


Value* operator+(Value &lVal, Value *rVal);
Value* operator-(Value &lVal, Value *rVal);
Value* operator*(Value &lVal, Value *rVal);
Value* operator/(Value &lVal, Value *rVal);
Value* operator==(Value &lVal, Value *rVal);
Value* operator!=(Value &lVal, Value *rVal);
Value* operator>(Value &lVal, Value *rVal);
Value* operator<(Value &lVal, Value *rVal);
Value* operator>=(Value &lVal, Value *rVal);
Value* operator<=(Value &lVal, Value *rVal);

#endif
