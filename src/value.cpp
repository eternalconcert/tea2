#include <string.h>
#include <cmath>
#include <string>
#include "exceptions.h"
#include "ast/ast.h"
#include "valuestore.h"
#include "value.h"

static char* copyString(const std::string &value) {
    char *copy = new char[value.size() + 1];
    memcpy(copy, value.data(), value.size());
    copy[value.size()] = '\0';
    return copy;
}

static std::string valueString(Value *value) {
    return std::string(value->stringValue, value->stringLength);
}

Value *copyValueDeep(const Value *src) {
    if (src == nullptr) {
        return nullptr;
    }
    Value *n = new Value();
    n->location = src->location;
    n->assigned = src->assigned;
    switch (src->type) {
        case STR:
            n->type = STR;
            n->boolValue = src->boolValue;
            n->stringLength = src->stringLength;
            n->stringValue = src->stringValue ? copyString(std::string(src->stringValue, src->stringLength)) : nullptr;
            return n;
        case INT:
            n->set(src->intValue, src->location);
            return n;
        case FLOAT:
            n->set(src->floatValue, src->location);
            return n;
        case BOOL:
            n->set(src->boolValue, src->location);
            return n;
        case DICT: {
            std::map<std::string, Value *> m;
            for (const auto &p : src->dictValue) {
                m[p.first] = copyValueDeep(p.second);
            }
            n->set(m, src->location);
            return n;
        }
        case ARRAY: {
            std::vector<Value *> v;
            for (Value *x : src->arrayValue) {
                v.push_back(copyValueDeep(x));
            }
            n->set(v, src->location);
            return n;
        }
        case IDENTIFIER:
            n->type = IDENTIFIER;
            n->scope = src->scope;
            n->identValue = src->identValue ? copyString(std::string(src->identValue)) : nullptr;
            return n;
        case FUNCTION:
            n->setFn(src->identValue, src->scope, src->functionBody, src->location);
            return n;
        case FUNCTIONCALL:
            n->setFnCall(src->identValue, src->retNode, src->scope, src->location);
            return n;
        default:
            n->set(src->type, src->location);
            return n;
    }
}

static void reprArrayItem(Value *value) {
    if (value->getTrueType() == STR) {
        printf("\"");
        fwrite(value->stringValue, 1, value->stringLength, stdout);
        printf("\"");
        return;
    }

    value->repr();
}

static void reprDictItem(Value *value) {
    if (value->getTrueType() == STR) {
        printf("\"");
        fwrite(value->stringValue, 1, value->stringLength, stdout);
        printf("\"");
        return;
    }

    value->repr();
}

void Value::set(typeId type, YYLTYPE location) {
    this->type = type;
    this->location = location;
    this->assigned = false;
};

void Value::set(char *value, YYLTYPE location) {
    this->type = STR;
    this->location = location;
    this->stringLength = strlen(value);
    this->boolValue = this->stringLength > 0;
    this->stringValue = value;
};

void Value::set(const std::string &value, YYLTYPE location) {
    this->type = STR;
    this->location = location;
    this->stringLength = value.size();
    this->boolValue = this->stringLength > 0;
    this->stringValue = copyString(value);
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

void Value::set(std::vector<Value*> value, YYLTYPE location) {
    this->type = ARRAY;
    this->location = location;
    this->boolValue = value.size() > 0;
    this->arrayValue = value;
};

void Value::set(std::map<std::string, Value*> value, YYLTYPE location) {
    this->type = DICT;
    this->location = location;
    this->boolValue = value.size() > 0;
    this->dictValue = value;
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

int Value::toInt(YYLTYPE location) {
    int num;
    switch (this->type) {
        case STR:
            num = std::stoi(this->stringValue);
            this->set(num, this->location);
            this->type = INT;
            break;
    }
    return num;
};

char* Value::toStr(YYLTYPE location) {
    char *str = nullptr;
    switch (this->type) {
        case INT:
            std::string temp = std::to_string(this->intValue);
            this->set(temp, location);
            str = this->stringValue;
            this->type = STR;
            break;
    }
    return str;
};


void Value::repr() {
    switch (this->type) {
        case STR:
            fwrite(this->stringValue, 1, this->stringLength, stdout);
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
        case ARRAY:
            printf("[");
            for (int i = 0; i < this->arrayValue.size(); i++) {
                if (i > 0) {
                    printf(", ");
                }
                reprArrayItem(this->arrayValue[i]);
            }
            printf("]");
            break;
        case DICT: {
            printf("{");
            bool first = true;
            for (auto const& item : this->dictValue) {
                if (!first) {
                    printf(", ");
                }
                first = false;
                printf("\"%s\": ", item.first.c_str());
                reprDictItem(item.second);
            }
            printf("}");
            break;
        }
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
        nVal->set(tempStr + valueString(rVal), lVal.location);
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
        nVal->set(tempStr + valueString(rVal), lVal.location);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "A" + 1 = "A1"
        std::string tempStr = std::to_string(rVal->intValue);
        nVal->set(valueString(&lVal) + tempStr, lVal.location);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" + 1.0 = "A1.0"
        std::string tempStr = std::to_string(rVal->floatValue);
        nVal->set(valueString(&lVal) + tempStr, lVal.location);
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "A" + "B" = "AB"
        nVal->set(valueString(&lVal) + valueString(rVal), lVal.location);
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
        size_t removeCount = rVal->intValue < 0 ? 0 : (size_t)rVal->intValue;
        size_t newLength = removeCount >= lVal.stringLength ? 0 : lVal.stringLength - removeCount;
        nVal->set(std::string(lVal.stringValue, newLength), lVal.location);
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
        std::string repeated;

        for (int i=0; i < lVal.intValue; i++) {
            repeated += valueString(rVal);
        }
        nVal->set(repeated, lVal.location);
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
        std::string repeated;

        for (int i=0; i < rVal->intValue; i++) {
            repeated += valueString(&lVal);
        }
        nVal->set(repeated, lVal.location);
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
        size_t newLength = (lVal.stringLength / rVal->intValue) + 1;
        if (newLength > lVal.stringLength) {
            newLength = lVal.stringLength;
        }
        nVal->set(std::string(lVal.stringValue, newLength), lVal.location);
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
        nVal->set(lVal.stringLength == rVal->stringLength && memcmp(lVal.stringValue, rVal->stringValue, lVal.stringLength) == 0, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == BOOL and rVal->getTrueType() == BOOL) {
        // true == true = true
        nVal->set(lVal.boolValue == rVal->boolValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == ARRAY and rVal->getTrueType() == ARRAY) {
        if (lVal.arrayValue.size() != rVal->arrayValue.size()) {
            nVal->set(false, lVal.location);
            return nVal;
        }

        for (int i = 0; i < lVal.arrayValue.size(); i++) {
            Value *itemsEqual = operator==(*lVal.arrayValue[i], rVal->arrayValue[i]);
            if (!itemsEqual->boolValue) {
                nVal->set(false, lVal.location);
                return nVal;
            }
        }

        nVal->set(true, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == DICT and rVal->getTrueType() == DICT) {
        if (lVal.dictValue.size() != rVal->dictValue.size()) {
            nVal->set(false, lVal.location);
            return nVal;
        }

        for (auto const& item : lVal.dictValue) {
            if (rVal->dictValue.find(item.first) == rVal->dictValue.end()) {
                nVal->set(false, lVal.location);
                return nVal;
            }

            Value *itemsEqual = operator==(*item.second, rVal->dictValue[item.first]);
            if (!itemsEqual->boolValue) {
                nVal->set(false, lVal.location);
                return nVal;
            }
        }

        nVal->set(true, lVal.location);
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
        nVal->set(lVal.intValue > rVal->stringLength, lVal.location);
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
        nVal->set(lVal.floatValue > rVal->stringLength, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == INT) {
        // "A" > 3 = false
        nVal->set(lVal.stringLength > rVal->intValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == FLOAT) {
        // "A" > 3.0 = false
        nVal->set(lVal.stringLength > rVal->floatValue, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == STR and rVal->getTrueType() == STR) {
        // "AB" > "C" = true
        nVal->set(lVal.stringLength > rVal->stringLength, lVal.location);
        return nVal;
    }

    if (lVal.getTrueType() == BOOL and rVal->getTrueType() == INT) {
        nVal->set(lVal.boolValue && rVal->intValue > 0, lVal.location);
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
