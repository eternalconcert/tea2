#ifndef COMMONS_H
#define COMMONS_H
#include <string>

enum typeId {INT, FLOAT, STR, BOOL, VOID, ARRAY, IDENTIFIER, FUNCTION, FUNCTIONCALL, UNDEFINED};

typeId getTypeIdByName(std::string name);

std::string getTypeNameById(typeId id);


#endif
