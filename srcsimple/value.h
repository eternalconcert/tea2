#ifndef VALUE_H
#define VALUE_H
#include <map>
#include <string>
#include "commons.h"

class Value {
public:
    std::string ident;
    typeId type;
    int intValue;
    float floatValue;
    char *stringValue;
    bool boolValue;

    void set(char *value) {
        this->type = STR;
        this->stringValue = value; // Undefined reference in linker when implemendet in .cpp
    };

    void set(int value) {
        this->type = INT;
        this->intValue = value;
    };

    void set(float value) {
        this->type = FLOAT;
        this->floatValue = value;
    };

    void set(bool value) {
        this->type = BOOL;
        this->boolValue = value;
    };

    void repr() {
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
        }

    }


};

extern std::map <char*, Value*> constants;

#endif
