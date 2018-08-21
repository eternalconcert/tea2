#include <map>

enum types {INT, STR, BOOL, VOID, ARRAY};

class Constant {
    std::string ident;
    types type;
    int int_value;
    std::string string_value;
    bool bool_value;

    public:
        void setValue();
};


void Constant::setValue() {
    printf("%s\n", "JAA");
}

std::map <std::string, Constant> constants;
