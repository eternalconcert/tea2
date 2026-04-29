#include <cstdio>
#include <stdexcept>
#include "value.h"
#include "../y.tab.h"

static inline void printTeaErrorLocation(const YYLTYPE &location) {
    if (!location.filename.empty()) {
        printf("%s:%i:%i: ", location.filename.c_str(), location.first_line, location.first_column);
    } else {
        printf("%i:%i: ", location.first_line, location.first_column);
    }
}

class BaseError: public std::exception {
public:
    BaseError(std::string message, YYLTYPE location) {
        printTeaErrorLocation(location);
        printf("%s\n", message.c_str());
        exit(47);
    };
};

class ParserError: public std::exception {
public:
    ParserError(std::string message) {
        printf("ParserError: %s\n", message.c_str());
        exit(2);
    };
};

class RuntimeError: public std::exception {
public:
    RuntimeError(std::string message, YYLTYPE location) {
        printTeaErrorLocation(location);
        printf("RuntimeError: %s\n", message.c_str());
        exit(3);
    };
};

class TypeError: public std::exception {
public:
    TypeError(std::string message, YYLTYPE location) {
        printTeaErrorLocation(location);
        printf("TypeError: %s\n", message.c_str());
        exit(3);
    };
};


class UnknownIdentifierError: public std::exception {
public:
    UnknownIdentifierError(std::string message, YYLTYPE location) {
        printTeaErrorLocation(location);
        printf("UnknownIdentifierError: %s\n", message.c_str());
        exit(4);
    };
};


class UnassignedIdentifierError: public std::exception {
public:
    UnassignedIdentifierError(std::string message, YYLTYPE location) {
        printTeaErrorLocation(location);
        printf("UnassignedIdentifierError: %s\n", message.c_str());
        exit(5);
    };
};


class FileNotFoundException: public std::exception {
public:
    FileNotFoundException(std::string message, YYLTYPE location) {
        printTeaErrorLocation(location);
        printf("FileNotFound: %s\n", message.c_str());
        exit(7);
    };
};


class AssertionError: public std::exception {
public:
  AssertionError(Value *first, Value *second, YYLTYPE location) {
        printTeaErrorLocation(location);
        printf("AssertionError: ");
        first->repr();
        printf(" != ");
        second->repr();
        printf("\n");
        exit(7);
    };

  AssertionError(Value *first, Value *second, std::string message, YYLTYPE location) {
        printTeaErrorLocation(location);
        printf("AssertionError: %s: ", message.c_str());
        first->repr();
        printf(" != ");
        second->repr();
        printf("\n");
        exit(7);
    };
};


class ParameterError: public std::exception {
public:
    ParameterError(std::string message) {
        printf("ParameterError: %s\n", message.c_str());
        exit(8);
    };
};


class SystemError: public std::exception {
public:
    SystemError(std::string message) {
        printf("SystemError: %s\n", message.c_str());
        exit(9);
    };
};
