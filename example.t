#!/usr/bin/tea

5 - 1;
1 + 3;


int var_number = 11233;
int var_number_no_assignment;
var_number_no_assignment = 1;
var_number_no_assignment = 2;
print(var_number_no_assignment);

bool boolean_var = true;
print(boolean_var);

str var_string_no_assignment;
str var_string = "String";

int fn addition(int formal_param1, int formal_param2) {
    int result;
    result = formal_param1 + formal_param2;
    return result;
};

str message1 = "This is an outer scope string variable it should appear unchanged far below.";
void fn empty(int formal_param1, int formal_param2) {
    print(message1);
    message1 = "Right here it should be changed";
    void fn empty() {
        print(message1);
        int message2 = 1;
        int message2 = 3;
    };
};
print("Next one must be like the first one");
print(message1);

int var_number_no_assignment_1 = addition(3, 2);
int var_number_no_assignment_2 = addition(5, 3);

1 + 1;
2 - 2;
3 * 3;
4 / 4;

float number = -0.5;

int res = 1 + 2;
int res2 = res - 4;
int res3 = 3 * 3;
int res4 = 9 / 3;
res4 = 3 * 3 + 4;

array list1 = [1, 2, 3, "Hello ", "world!"];
int item = 0;
for (int i = 0; i < len(list1); i = i + 1) {
    item = item + 1;
    print("In der Schleife!");
};

if (var_number == 1 and var_number != 0) {
    item = item + 1;
    print("Im If-Block!");
};

if (var_number == 1 || var_number != 0) {
    item = item + 1;
    print("Im If-Block!");
} else {
    item = item + 2;
    print("Im Else-Block!");
};

print("Hallo Welt!");
print(23235);
print(23235.2);
str result = cmd("pwd");
print(result);
str command = "echo 'Hello from the world!'";
print(cmd(command));


int number1 = 12;
int number2 = 3333;
print(number2);

1 + 1;

int test;
test = 21;
array list2 = [12, test];
print(list2);
