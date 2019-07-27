#ifndef VALUE_H
#define VALUE_H
#include <map>
#include <string>
#include "commons.h"

class Value {
public:
    std::string unused;
    typeId type;
    int intValue;
    float floatValue;
    char *stringValue;
    bool boolValue;
    char *identValue;

    void set(char *value);
    void set(int value);
    void set(float value);
    void set(bool value);
    void setIdent(char *value);
    void repr();
};

#endif
