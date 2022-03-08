%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

using namespace std;


struct Atributos {
  string c;
};

#define YYSTYPE Atributos

int yylex();
int yyparse();
void yyerror(const char *);
int linha = 1;
int coluna = 1;
int ultimo_token = -1;

%}

%token NUM ID LET STRING IF FOR WHILE SUB ADD MUL DIV MEN MAI MEG MAG IGU DIF FIM_DE_LINHA

// Start indica o símbolo inicial da gramática
%start S

%%

S : CMDs { cout << $1.c << "." << endl; }
  ;

// BLOCO : '{' CMDs '}'
//       | '{' CMDs BLOCO '}'
//       | '{''}'                    { $$.c = ""; }

SEPARADOR : ';'           
          | FIM_DE_LINHA  
          ;

CMDs : CMD SEPARADOR CMDs   { $$.c = $1.c + "\n" + $3.c;}
     | { $$.c = ""; }
     ;

CMD : A { $$.c = $1.c + " ^";}
    | LET DECLVARs { $$.c = $2.c; }
    ;

DECLVARs : DECLVAR ',' DECLVARs { $$.c = $1.c + " " + $3.c; }
         | DECLVAR              { $$.c = $1.c; }
         ;

DECLVAR : ID '=' E { $$.c = $1.c + " & " + $1.c + " "  + $3.c + " = ^"; }
        | ID { $$.c = $1.c + " & ";}
        ;


A : ID '=' A { $$.c = $1.c + " " + $3.c + " ="; }
  | E        
  ;

E : E '+' T { $$.c = $1.c + " " + $3.c + " +"; }
  | E '-' T { $$.c = $1.c + " " + $3.c + " -"; }
  | T
  ;

T : T '*' F { $$.c = $1.c + " " + $3.c + " *"; }
  | T '/' F { $$.c = $1.c + " " + $3.c + " /"; }
  | F

F : ID          { $$.c = $1.c + " @"; }
  | NUM         { $$.c = $1.c; }
  | STRING      { $$.c = $1.c; }
  | '(' E ')'   { $$.c = $2.c; }
  | '{' '}'     { $$.c = "{}";}
  | '[' ']'     { $$.c = "[]";}
  ;


%%

#include "lex.yy.c"

void yyerror( const char* st ) {
   puts( st ); 
   printf( "Proximo a: %s\n na linha: %d e coluna: %d\n", yytext, linha, coluna );
   exit( 1 );
}

int main( int argc, char* argv[] ) {
  yyparse();
  
  return 0;
}