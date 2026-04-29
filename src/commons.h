#ifndef COMMONS_H
#define COMMONS_H
#include <string>
#include <vector>

extern std::vector<std::string> parseFileStack;
void tea_reset_lexer_column(void);

enum typeId {UNDEFINED=0, INT=1, FLOAT=2, STR=3, BOOL=4, VOID=5, ARRAY=6, DICT=7, IDENTIFIER=8, FUNCTION=9, FUNCTIONCALL=10};

enum StmtType { RETURN=0, IF=1, OTHER=2 };

#endif
