#include <stdexcept>


class RuntimeError: public std::exception {
    public:
        RuntimeError(std::string message) {
            printf("RuntimeError: %s\n", message.c_str());
            exit(1);
        };
};
