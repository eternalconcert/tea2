#include "exceptions.h"
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
            if (global->constants.find(this->identValue) != global->constants.end()) {
                global->constants[this->identValue]->repr();
            }
            else {
                throw (UnknownIdentifierError());
            }
            break;
    }
}

Scope *global = new Scope();
