![Tests](https://github.com/eternalconcert/tea2/workflows/Tests/badge.svg?branch=master)

# Tea2
The Tea Programming Language

## Compilation (Linux)

At the repositories root:
```bash
make tea
```

Or without make:
```bash
lex src/patterns.l
yacc -d src/grammar.y
g++ lex.yy.c y.tab.c $(find src/ -name "*.cpp") -o tea --static
```

The result will be a binary file called `tea`.

## First run
The mandatory `hello world` can be easly achieved with:
```bash
./tea -c 'print("hello world");'
```
This will print the message to the STDOUT.

## Running a program
Create a file next to the Tea binary, called `first_steps.t`, containing the following code:
```c
str greeting = "It's tea time!";
print(greeting);
```

Run the program with
```bash
./tea first_steps.t
```

The following code will list the current directories content:
```c
str directory_content = cmd("ls");
print(directory_content);
```

Another example:
```c
str name = input;
print("hello ", name);
};
```

And finally a little use case:
```c
print("A little quiz?\n");

int correct_answers = 0;
str correct = "Yes, that was the right answer.\n";
str wrong = "Nope, that was wrong.\n";

stdout("Who is the best Star Trek captain? ");
str answer_1 = input;
if (answer_1 == "Picard") {
  correct_answers = correct_answers + 1;
  print(correct);
} else {
  print(wrong);
};

stdout("Tabs or spaces? ");
str answer_2 = input;
if (answer_2 == "spaces") {
  correct_answers = correct_answers + 1;
  print(correct);
} else {
  print(wrong);
};

stdout("I am your... ");
str answer_3 = input;
if (answer_3 == "father") {
  correct_answers = correct_answers + 1;
  print(correct);
} else {
  print(wrong);
};

print("Thank you!\nYou have ", correct_answers, " answers right.");

if (correct_answers == 0) {
  print("You noop!");
};

if (correct_answers == 1) {
  print("You shall not pass!");
};

if (correct_answers == 2) {
  print("You are on a good way.");
};

if (correct_answers > 2) {
  print("You are a nerd.");
  print("Or you read the source code. Which makes you also a nerd.");
};

if (correct_answers > 3) {
  print("This cannot happen.");
};
```