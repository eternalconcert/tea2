str fn privateHelper() {
    return "hidden";
};

export str fn exportedHelper() {
    return privateHelper();
};
