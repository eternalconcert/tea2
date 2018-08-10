%{
    extern "C" {
        int yyparse(void);
        int yylex(void);

        int yywrap() {
            return 1;
        }

    }

    #include <stdio.h>
    #include <string.h>

    void yyerror(const char *str) {
        fprintf(stderr, "Error: %s\n", str);
    }

    main() {
        yyparse();
    }
%}

%token NUMBER TOKHEAT STATE TOKTARGET TOKTEMPERATURE

%%

commands: /* empty */
        | commands command
        ;

command:
        heat_switch
        |
        target_set
        ;

heat_switch:
        TOKHEAT STATE
        {
            if ($2) {
                printf("Heat turned on\n");
            }
            else {
                printf("Heat turned off\n");
            }
        }

target_set:
        TOKTARGET TOKTEMPERATURE NUMBER
        {
            printf("Temperature set to %d\n", $3);
        }
