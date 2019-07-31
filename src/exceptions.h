#include <stdexcept>


class RuntimeError: public std::exception {
public:
    RuntimeError(std::string message) {
        printf("RuntimeError: %s\n", message.c_str());
        exit(1);
    };
};


class ParserError: public std::exception {
public:
    ParserError(std::string message) {
        printf("ParserError: %s\n", message.c_str());
        exit(1);
    };
};


class TypeError: public std::exception {
public:
    TypeError(std::string message) {
        printf("TypeError! %s\n", message.c_str());
        exit(1);
    };
};


class UnknownIdentifierError: public std::exception {
public:
    UnknownIdentifierError() {
        printf("UnknownIdentifierError!\n");
        exit(1);
    };
};


class ConstError: public std::exception {
public:
    ConstError() {
        printf("ConstError!\n");
        exit(1);
    };
};
