#!/usr/bin/tea

5 - 1;
1 + 3;


INT var_number = 11233;
INT var_number_no_assignment;
var_number_no_assignment = 1;
var_number_no_assignment = 2;
print(var_number_no_assignment);

BOOL boolean_var = true;
print(boolean_var);

STR var_string_no_assignment;
STR var_string = "String";

INT FN addition(INT formal_param1, INT formal_param2) {
    INT result;
    result = formal_param1 + formal_param2;
    return result;
};

STR message1 = "This is an outer scope string variable it should appear unchanged far below.";
VOID FN empty(INT formal_param1=1, INT formal_param2) {
    print(message1);
    message1 = "Right here it should be changed";
    FN VOID empty() {
        print(message1);
        INT message2 = 1;
        INT message2 = 3;
    };
};
print("Next one must be like the first one");
print(message1);

var_number_no_assignment_1 = addition(3, 2);
INT var_number_no_assignment_2 = addition(5, 3);

1 + 1;
2 - 2;
3 * 3;
4 / 4;

FLOAT number = -0.5;

res = 1 + 2;
INT res2 = res - 4;
INT res3 = 3 * 3;
INT res4 = 9 / 3;
res4 = 3 * 3 + 4;

for item in list1 {
    item = item + 1;
    print("In der Schleife!");
};

if var_number == 1 or var_number not in list1 and var_number != 0 {
    item = item + 1;
    print("Im If-Block!");
};

if var_number == 1 or var_number not in list1 and var_number != 0 {
    item = item + 1;
    print("Im If-Block!");
}
else {
    item = item + 2;
    print("Im Else-Block!");
};

print("Hallo Welt!");
print(23235);
print(23235.2);
command("echo 'Hello world!'");
STR command = "echo 'Hello from the world!'";
command(command);

INT test;

a;
1.2;
-12;


INT number1 = 12;
INT number2 = 3333;
print(number2);


1 + 1;

ARRAY list2 = [12, test];
print(list2);
