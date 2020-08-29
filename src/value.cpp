#include <string.h>
#include <cmath>
#include "exceptions.h"
#include "ast/ast.h"
#include "valuestore.h"
#include "value.h"

void Value::set(typeId type, YYLTYPE location) {
    this->type = type;
    this->location = location;
    this->assigned = false;
};

void Value::set(char *value, YYLTYPE location) {
    this->type = STR;
    this->location = location;
    this->boolValue = strlen(value) > 0;
    this->stringValue = value;
};

void Value::set(int value, YYLTYPE location) {
    this->type = INT;
    this->location = location;
    this->boolValue = value > 0;
    this->intValue = value;
};

void Value::set(float value, YYLTYPE location) {
    this->type = FLOAT;
    this->location = location;
    this->boolValue = value > 0;
    this->floatValue = value;
};

void Value::set(bool value, YYLTYPE location) {
    this->type = BOOL;
    this->location = location;
    this->boolValue = value;
};

void Value::setIdent(char *value, AstNode *scope, YYLTYPE location) {
    this->scope = scope;
    this->type = IDENTIFIER;
    this->location = location;
    this->identValue = value;
};

void Value::setFn(char *identifier, AstNode *scope, FnDeclarationNode *functionBody, YYLTYPE location) {
    this->scope = scope;
    this->functionBody = functionBody;
    this->type = FUNCTION;
    this->location = location;
    this->identValue = identifier;
};

void Value::setFnCall(char *value, AstNode *retNode, AstNode *scope, YYLTYPE location) {
    this->scope = scope;
    this->retNode = retNode;
    this->type = FUNCTIONCALL;
    this->location = location;
    this->identValue = value;
};


void Value::repr() {
    switch (this->type) {
        case STR:
            printf("%s", this->stringValue);
            break;
        case INT:
            printf("%i", this->intValue);
            break;
        case FLOAT:
            printf("%f", this->floatValue);
            break;
        case BOOL:
            printf("%s", this->boolValue ? "true" : "false");
            break;
        case IDENTIFIER:
            getFromValueStore(this->scope, this->identValue, this->location)->repr();
            break;
        case FUNCTION:
            printf("Function: %s", this->identValue);
            break;
    }
}

typeId Value::getTrueType() {
    if ((this->type != IDENTIFIER) and (this->type != FUNCTION)) {
        return (this->type);
    }
    // else: Identifier or function
    return getFromValueStore(this->scope, this->identValue, this->location)->type;
}

Value* operator+(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    if (lVal.getTrueType() == INT and rVal->getTrueType() == INT) {
        // 1 + 1 = 2
        nVal->set(lVal.intValue + rVal->intValue, lVal.location);
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == FLOAT) {
        // 1 + 1.0 = 2.0
        nVal->set(lVal.intValue + rVal->floatValue, lVal.location);
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == STR) {
        // 1 + "A" = "1A"
        std::string tempStr = std::to_string(lVal.intValue);
        char* cStr = new char[tempStr.length() + strlen(rVal->stringValue)];
        strcpy(cStr, tempStr.c_str());
        strcat(cStr, rVal->stringValue);
        nVal->set(cStr, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == INT) {
        // 1.0 + 1 = 2.0
        nVal->set(lVal.floatValue + rVal->intValue, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == FLOAT) {
        // 1.0 + 1.0 = 2.0
        nVal->set(lVal.floatValue + rVal->floatValue, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == STR) {
        // 1.0 + "A" = "1.0A"
        std::string tempStr = std::to_string(lVal.floatValue);
        char* cStr = new char[tempStr.length() + strlen(rVal->stringValue)];
        strcpy(cStr, tempStr.c_str());
        strcat(cStr, rVal->stringValue);
        nVal->set(cStr, lVal.location);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "A" + 1 = "A1"
        std::string tempStr = std::to_string(rVal->intValue);
        char* cStr = new char[tempStr.length() + strlen(lVal.stringValue)];
        strcpy(cStr, lVal.stringValue);
        strcat(cStr, tempStr.c_str());
        nVal->set(cStr, lVal.location);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" + 1.0 = "A1.0"
        std::string tempStr = std::to_string(rVal->floatValue);
        char* cStr = new char[tempStr.length() + strlen(lVal.stringValue)];
        strcpy(cStr, lVal.stringValue);
        strcat(cStr, tempStr.c_str());
        nVal->set(cStr, lVal.location);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "A" + "B" = "AB"
        char* cStr = new char[strlen(lVal.stringValue) + strlen(rVal->stringValue)];
        strcpy(cStr, lVal.stringValue);
        strcat(cStr, rVal->stringValue);
        nVal->set(cStr, lVal.location);
    }

    if (lVal.getTrueType() == BOOL or rVal->getTrueType() == BOOL) {
        // true + false = XXX
        throw (TypeError("Addition is not implemented for BOOL", lVal.location));

    }
    return nVal;
};


Value* operator-(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    if (lVal.getTrueType() == INT and rVal->getTrueType() == INT) {
        // 100 + 70 = 30;
        nVal->set(lVal.intValue - rVal->intValue, lVal.location);

    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == FLOAT) {
        // 100 - 1.0 = 99.0
        nVal->set(lVal.intValue - rVal->floatValue, lVal.location);
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == STR) {
        // 1 - "A" = XXX
        throw (TypeError("Substraction is not implemented for INT and STR", lVal.location));
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == INT) {
        // 100.0 - 1 = 99.0
        nVal->set(lVal.floatValue - rVal->intValue, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == FLOAT) {
        // 100.0 - 1.0 = 99.0
        nVal->set(lVal.floatValue - rVal->floatValue, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == STR) {
        // 1.0 - "A" = XXX
        throw (TypeError("Substraction is not implemented for FLOAT and STR", lVal.location));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "Hello" - 1 = "Hell"
        if(strlen(lVal.stringValue) <= rVal->intValue) {
            for (int i = 0; i <= strlen(lVal.stringValue); i++) {
                lVal.stringValue[i] = 0;
            }
        }
        else {
            lVal.stringValue[strlen(lVal.stringValue) - rVal->intValue] = 0;
        }
            nVal->set(lVal.stringValue, lVal.location);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" - 1.0 = XXX
        throw (TypeError("Substraction is not implemented for STR and FLOAT", lVal.location));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "A" - "B" = XXX
        throw (TypeError("Substraction is not implemented for STR and STR", lVal.location));
    }

    if (lVal.getTrueType() == BOOL or rVal->getTrueType() == BOOL) {
        // true - false = XXX
        throw (TypeError("Substraction is not implemented for BOOL", lVal.location));

    }
    return nVal;
};


Value* operator*(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    if (lVal.getTrueType() == INT and rVal->getTrueType() == INT) {
        // 3 * 3 = 9
        nVal->set(lVal.intValue * rVal->intValue, lVal.location);

    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == FLOAT) {
        // 3 + 3.0 = 9.0
        nVal->set(lVal.intValue * rVal->floatValue, lVal.location);
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == STR) {
        // 3 + "A" = "AAA"
        char* cStr = new char[(strlen(rVal->stringValue) * lVal.intValue)];

        for (int i=1; i <= lVal.intValue; i++) {
            strcat(cStr, rVal->stringValue);
        }
        nVal->set(cStr, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == INT) {
        // 3.0 * 2 = 6.0
        nVal->set(lVal.floatValue * rVal->intValue, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == FLOAT) {
        // 2.0 * 1.0 = 2.0
        nVal->set(lVal.floatValue * rVal->floatValue, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == STR) {
        // 2.0 * "A" = XXX
        throw (TypeError("Multiplication is not implemented for FLOAT and STR", lVal.location));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "A" * 3 = "AAA"
        char* cStr = new char[(strlen(lVal.stringValue) * rVal->intValue)];

        for (int i=1; i <= rVal->intValue; i++) {
            strcat(cStr, lVal.stringValue);
        }
        nVal->set(cStr, lVal.location);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" * 2.0 = XXX
        throw (TypeError("Multiplication is not implemented for STR and FLOAT", lVal.location));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "A" * "B" = XXX
        throw (TypeError("Multiplication is not implemented for STR and STR", lVal.location));
    }

    if (lVal.getTrueType() == BOOL or rVal->getTrueType() == BOOL) {
        // true * false = XXX
        throw (TypeError("Multiplication is not implemented for BOOL", lVal.location));

    }
    return nVal;
};

Value* operator/(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    if (lVal.getTrueType() == INT and rVal->getTrueType() == INT) {
        // 9 / 2 = 4
        nVal->set(lVal.intValue / rVal->intValue, lVal.location);

    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == FLOAT) {
        // 9 / 2.0 = 4.5
        nVal->set(lVal.intValue / rVal->floatValue, lVal.location);
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == STR) {
        // 2 / "A" = XXX
        throw (TypeError("Division is not implemented for INT and STR", lVal.location));
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == INT) {
        // 9.0 / 2 = 4.5
        nVal->set(lVal.floatValue / rVal->intValue, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == FLOAT) {
        // 2.0 + 2.0 = 1.0
        nVal->set(lVal.floatValue / rVal->floatValue, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == STR) {
        // 1.0 / "A" = XXX
        throw (TypeError("Division is not implemented for FLOAT and STR", lVal.location));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "Hello" / 2 = "Hel"

        lVal.stringValue[(strlen(lVal.stringValue) / rVal->intValue) + 1] = 0;
        nVal->set(lVal.stringValue, lVal.location);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" / 1.0 = XXX
        throw (TypeError("Division is not implemented for STR and FLOAT", lVal.location));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "A" / "B" = XXX
        throw (TypeError("Division is not implemented for STR and STR", lVal.location));
    }

    if (lVal.getTrueType() == BOOL or rVal->getTrueType() == BOOL) {
        // true / false = XXX
        throw (TypeError("Division is not implemented for BOOL", lVal.location));

    }
    return nVal;
};

Value* operator%(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    if (lVal.getTrueType() == INT and rVal->getTrueType() == INT) {
        // 10 % 3 = 1
        nVal->set(lVal.intValue % rVal->intValue, lVal.location);

    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == FLOAT) {
        // 10 / 3.0 = 1.0
        float v = std::fmod(lVal.intValue, rVal->floatValue);
        nVal->set(v, lVal.location);
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == STR) {
        // 2 % "A"
        throw (TypeError("Modulo is not implemented for INT and STR", lVal.location));
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == INT) {
        // 10.0 % 3 = 1.0
        float v = std::fmod(lVal.floatValue, rVal->intValue);
        nVal->set(v, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == FLOAT) {
        // 10.0 % 3.0 = 1.0
        float v = std::fmod(lVal.floatValue, rVal->floatValue);
        nVal->set(v, lVal.location);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == STR) {
        // 1.0 % "A"
        throw (TypeError("Modulo is not implemented for FLOAT and STR", lVal.location));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "Hello" % 2

        throw (TypeError("Modulo is not implemented for STR and INT", lVal.location));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" % 1.0
        throw (TypeError("Modulo is not implemented for STR and FLOAT", lVal.location));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "A" % "B"
        throw (TypeError("Modulo is not implemented for STR and STR", lVal.location));
    }

    if (lVal.getTrueType() == BOOL or rVal->getTrueType() == BOOL) {
        // true / false
        throw (TypeError("Modulo is not implemented for BOOL", lVal.location));

    }
    return nVal;
};


Value* operator==(Value &lVal, Value *rVal) {
    Value *nVal = new Value();

    if (lVal.getTrueType() != rVal->getTrueType()) {
        nVal->set(false, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == INT) {
        // 1 == 1 = true
        nVal->set(lVal.intValue == rVal->intValue, lVal.location);
        return nVal;

    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == FLOAT) {
        // 1.0 == 1.0 = true
        nVal->set(lVal.floatValue == rVal->floatValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "A" == "A" = true
        nVal->set((strcmp(lVal.stringValue, rVal->stringValue) == 0), lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == BOOL and rVal->getTrueType() == BOOL) {
        // true == true = true
        nVal->set(lVal.boolValue == rVal->boolValue, lVal.location);
        return nVal;
    }

    return nVal;
};


Value* operator!=(Value &lVal, Value *rVal) {
    Value *nVal = operator==(lVal, rVal);
    nVal->boolValue = !(nVal->boolValue);
    return nVal;
};

Value* operator>(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    if (lVal.getTrueType() == INT and rVal->getTrueType() == INT) {
        // 2 > 1 = true
        nVal->set(lVal.intValue > rVal->intValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == FLOAT) {
        // 2 > 1.0 = true
        nVal->set(lVal.intValue > rVal->floatValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == STR) {
        // 1 > "AA" = false
        nVal->set(lVal.intValue > strlen(rVal->stringValue), lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == INT) {
        // 2.0 > 1 = true
        nVal->set(lVal.floatValue > rVal->intValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == FLOAT) {
        // 2.0 > 1.0 = true
        nVal->set(lVal.floatValue > rVal->floatValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == STR) {
        // 2.0 > "A" = true
        nVal->set(lVal.floatValue > strlen(rVal->stringValue), lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "A" > 3 = false
        nVal->set(strlen(lVal.stringValue) > rVal->intValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" > 3.0 = false
        nVal->set(strlen(lVal.stringValue) > rVal->floatValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "AB" > "C" = true
        nVal->set(strlen(lVal.stringValue) > strlen(rVal->stringValue), lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == BOOL and rVal->getTrueType() == INT) {
        throw (TypeError("Size comparisons are not implemented for BOOL and INT", lVal.location));
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == BOOL) {
        throw (TypeError("Size comparisons are not implemented for INT and BOOL", lVal.location));
    }

    if (lVal.getTrueType() == BOOL and rVal->getTrueType() == BOOL) {
        // true > false = true
        nVal->set(lVal.boolValue > rVal->boolValue, lVal.location);
        return nVal;
    }

    return nVal;
};


Value* operator<(Value &lVal, Value *rVal) {
    Value *nVal = operator==(lVal, rVal);
    if (nVal->boolValue == true) {
        nVal->set(false, lVal.location);
        return nVal;
    }
    else {
        nVal = operator>(lVal, rVal);
        nVal->set(!(nVal->boolValue), lVal.location);
        return nVal;
    }
};


Value* operator>=(Value &lVal, Value *rVal) {
    Value *nVal = operator==(lVal, rVal);
    if (nVal->boolValue == true) {
        nVal->set(true, lVal.location);
        return nVal;
    }
    else {
        nVal = operator>(lVal, rVal);
        nVal->set(nVal->boolValue, lVal.location);
        return nVal;
    }
};

Value* operator<=(Value &lVal, Value *rVal) {
    Value *nVal = operator==(lVal, rVal);
    if (nVal->boolValue == true) {
        nVal->set(true, lVal.location);
        return nVal;
    }
    else {
        nVal = operator<(lVal, rVal);
        nVal->set(nVal->boolValue, lVal.location);
        return nVal;
    }
};

Value* operator&&(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    nVal->set(lVal.boolValue && rVal->boolValue, lVal.location);
    return nVal;
};

Value* operator||(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    nVal->set(lVal.boolValue || rVal->boolValue, lVal.location);
    return nVal;
};
