print();

INT FN test() {
    if (true) {
        return 1;
        print("-------------------------");
    };
    print("Should not be visible");
};

test();
print("Here");
