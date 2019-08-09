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
        exit(2);
    };
};


class TypeError: public std::exception {
public:
    TypeError(std::string message) {
        printf("TypeError! %s\n", message.c_str());
        exit(3);
    };
};


class UnknownIdentifierError: public std::exception {
public:
    UnknownIdentifierError(std::string message) {
        printf("UnknownIdentifierError: %s\n", message.c_str());
        exit(4);
    };
};


class UnassignedIdentifierError: public std::exception {
public:
    UnassignedIdentifierError(std::string message) {
        printf("UnassignedIdentifierError: %s\n", message.c_str());
        exit(5);
    };
};


class ConstError: public std::exception {
public:
    ConstError(std::string message) {
        printf("ConstError: %s\n", message.c_str());
        exit(6);
    };
};
