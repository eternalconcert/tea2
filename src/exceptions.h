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
    UnknownIdentifierError(std::string message) {
        printf("UnknownIdentifierError: %s\n", message.c_str());
        exit(1);
    };
};


class ConstError: public std::exception {
public:
    ConstError(std::string message) {
        printf("ConstError, identifier already in use for a constant: %s\n", message.c_str());
        exit(1);
    };
};
