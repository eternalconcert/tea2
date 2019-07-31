#include <string.h>
#include "exceptions.h"
#include "scope.h"
#include "value.h"


void Value::set(char *value) {
    this->type = STR;
    this->stringValue = value;
};

void Value::set(int value) {
    this->type = INT;
    this->intValue = value;
};

void Value::set(float value) {
    this->type = FLOAT;
    this->floatValue = value;
};

void Value::set(bool value) {
    this->type = BOOL;
    this->boolValue = value;
};

void Value::setIdent(char *value) {
    this->type = IDENTIFIER;
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
            if (constGlobal->valueStore.find(this->identValue) != constGlobal->valueStore.end()) {
                constGlobal->valueStore[this->identValue]->repr();
            }
            else {
                throw (UnknownIdentifierError());
            }
            break;
    }
}

typeId Value::getTrueType() {
    if (this->type != IDENTIFIER) {
        return (this->type);
    }
    return constGlobal->valueStore[this->identValue]->type;
}

Value* operator+(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    if (lVal.getTrueType() == INT and rVal->getTrueType() == INT) {
        // 1 + 1 = 2
        nVal->set(lVal.intValue + rVal->intValue);

    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == FLOAT) {
        // 1 + 1.0 = 2.0
        nVal->set(lVal.intValue + rVal->floatValue);
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == STR) {
        // 1 + "A" = "1A"
        std::string tempStr = std::to_string(lVal.intValue);
        char* cStr = new char[tempStr.length() + sizeof(rVal->stringValue)];
        strcpy(cStr, tempStr.c_str());
        strcat(cStr, rVal->stringValue);
        nVal->set(cStr);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == INT) {
        // 1.0 + 1 = 2.0
        nVal->set(lVal.floatValue + rVal->intValue);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == FLOAT) {
        // 1.0 + 1.0 = 2.0
        nVal->set(lVal.floatValue + rVal->floatValue);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == STR) {
        // 1.0 + "A" = "1.0A"
        std::string tempStr = std::to_string(lVal.floatValue);
        char* cStr = new char[tempStr.length() + sizeof(rVal->stringValue)];
        strcpy(cStr, tempStr.c_str());
        strcat(cStr, rVal->stringValue);
        nVal->set(cStr);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "A" + 1 = "A1"
        std::string tempStr = std::to_string(rVal->intValue);
        char* cStr = new char[tempStr.length() + sizeof(lVal.stringValue)];
        strcpy(cStr, lVal.stringValue);
        strcat(cStr, tempStr.c_str());
        nVal->set(cStr);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" + 1.0 = "A1.0"
        std::string tempStr = std::to_string(rVal->floatValue);
        char* cStr = new char[tempStr.length() + sizeof(lVal.stringValue)];
        strcpy(cStr, lVal.stringValue);
        strcat(cStr, tempStr.c_str());
        nVal->set(cStr);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "A" + "B" = "AB"
        char* cStr = new char[sizeof(lVal.stringValue)+ sizeof(rVal->stringValue)];
        strcpy(cStr, lVal.stringValue);
        strcat(cStr, rVal->stringValue);
        nVal->set(cStr);
    }

    if (lVal.getTrueType() == BOOL or rVal->getTrueType() == BOOL) {
        // true + false = XXX
        throw (TypeError("Addition is not implemented for BOOL"));

    }


    return nVal;
};


Value* operator-(Value &lVal, Value *rVal) {
    Value *nVal = new Value();
    if (lVal.getTrueType() == INT and rVal->getTrueType() == INT) {
        // 100 + 70 = 30;
        nVal->set(lVal.intValue - rVal->intValue);

    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == FLOAT) {
        // 100 - 1.0 = 99.0
        nVal->set(lVal.intValue - rVal->floatValue);
    }

    if (lVal.getTrueType() == INT and rVal->getTrueType() == STR) {
        // 1 - "A" = XXX
        throw (TypeError("Substraction is not implemented for INT and STR"));
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == INT) {
        // 100.0 - 1 = 99.0
        nVal->set(lVal.floatValue - rVal->intValue);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == FLOAT) {
        // 100.0 - 1.0 = 99.0
        nVal->set(lVal.floatValue - rVal->floatValue);
    }

    if (lVal.getTrueType() == FLOAT and rVal->getTrueType() == STR) {
        // 1.0 - "A" = XXX
        throw (TypeError("Substraction is not implemented for FLOAT and STR"));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "Hello" - 1 = "Hell"

        lVal.stringValue[strlen(lVal.stringValue) - rVal->intValue] = 0;
        nVal->set(lVal.stringValue);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" - 1.0 = XXX
        throw (TypeError("Substraction is not implemented for STR and FLOAT"));
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "A" - "B" = XXX
        throw (TypeError("Substraction is not implemented for STR and STR"));
    }

    if (lVal.getTrueType() == BOOL or rVal->getTrueType() == BOOL) {
        // true - false = XXX
        throw (TypeError("Substraction is not implemented for BOOL"));

    }


    return nVal;
};
