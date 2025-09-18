#ifndef VALUE_H
#define VALUE_H
#include <map>
#include <string>
#include "commons.h"

class AstNode;
class FnDeclarationNode;

#include "../y.tab.h"

class Value {
public:
    AstNode *scope;
    FnDeclarationNode *functionBody;
    AstNode *retNode;
    typeId type = UNDEFINED; // To check if a Value is present.. Not nice.
    typeId getTrueType();
    int intValue;
    float floatValue;
    char *stringValue;
    bool boolValue;
    char *identValue;
    bool assigned = true;
    YYLTYPE location;

    void set(typeId type, YYLTYPE location);  // Set emp, YYLTYPE locationty
    void set(char *value, YYLTYPE location);
    void set(int value, YYLTYPE location);
    void set(float value, YYLTYPE location);
    void set(bool value, YYLTYPE location);
    void setIdent(char *value, AstNode *scope, YYLTYPE location);
    void setFn(char *identifier, AstNode *scope, FnDeclarationNode *functionBody, YYLTYPE location);
    void setFnCall(char *value, AstNode *retNode, AstNode *scope, YYLTYPE location);
    void repr();

    int toInt(YYLTYPE location);
    char *toStr(YYLTYPE location);
};


Value* operator+(Value &lVal, Value *rVal);
Value* operator-(Value &lVal, Value *rVal);
Value* operator*(Value &lVal, Value *rVal);
Value* operator/(Value &lVal, Value *rVal);
Value* operator%(Value &lVal, Value *rVal);
Value* operator==(Value &lVal, Value *rVal);
Value* operator!=(Value &lVal, Value *rVal);
Value* operator>(Value &lVal, Value *rVal);
Value* operator<(Value &lVal, Value *rVal);
Value* operator>=(Value &lVal, Value *rVal);
Value* operator<=(Value &lVal, Value *rVal);
Value* operator&&(Value &lVal, Value *rVal);
Value* operator||(Value &lVal, Value *rVal);

#endif
