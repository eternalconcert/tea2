%{
    #include <stdio.h>
    #include <string.h>

    extern "C" {
        int yyparse(void);
        int yylex(void);

        int yywrap() {
            return 1;
        }

    }


    void yyerror(const char *str) {
        fprintf(stderr, "Error: %s\n", str);
    }

    main() {
        yyparse();
    }
%}

%token TOKCONST TOKHEAT TOKTARGET TOKTEMPERATURE

%union
{
    int number;
    char *string;
}

%token <string> TOKTYPEIDENT
%token <number> STATE
%token <number> NUMBER


%%

commands: /* empty */
        | commands command
        ;

command:
        heat_switch
        |
        target_set
        |
        const
        |
        typeidentifier
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

const:
    TOKCONST
    {
        printf("CONST!\n");
    }


typeidentifier:
    TOKTYPEIDENT
    {
        printf("Typeident: %s\n", $1);
    }
