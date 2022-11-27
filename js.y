%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <map>

using namespace std;


struct Atributos {
  vector<string> c;
  int l;
};

#define YYSTYPE Atributos

int yylex();
int yyparse();
void yyerror(const char *);
void print(vector<string> str);
vector<string> concatena( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, vector<string> b );
vector<string> operator+(vector<string> a, string b);
vector<string> operator+(string a, vector<string> b);
string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );
int tokeniza(int token);

int linha = 1;
int coluna = 1;
vector<string> atr;

%}

%token NUM ID LET STRING IF FOR WHILE SUB ADD MUL DIV MOD MEN MAI MEG MAG IGU DIF OBJ

%left MEN MAI IGU DIF MAG MEG
%left SUB ADD
%left MUL DIV MOD


// Start indica o símbolo inicial da gramática
%start S

%%

S : CMDs  { print( resolve_enderecos($1.c) ); }
  ;

CMDs : CMD ';' CMDs    { cout << "alooou" << endl;$$.c = $1.c + $3.c; }
     |                 { $$.c = atr; }
     ;

CMD : A                        { $$.c = $1.c + "^"; }
    | LET DECLVARS          { $$ = $2; }
    ;
			

DECLVARS : DECLVAR ',' DECLVARS  { $$.c = $1.c + $3.c; }
         | DECLVAR               { $$ = $1; }
         ;

DECLVAR : ID '=' E  { $$.c = $1.c + "&" + $1.c + $3.c + "=" + "^"; }
        | ID        { $$.c = $1.c + "&"; }
        ;

A : ID '=' A { $$.c = $1.c + " " + $3.c + " ="; }
  | E                              { $$ = $1; }
  ;


E : E MEG E        { $$.c = $1.c + $3.c + "<="; }
  | E MAG E        { $$.c = $1.c + $3.c + ">="; }
  |	E MEN E       { $$.c = $1.c + $3.c + "<"; }
  | E MAI E       { $$.c = $1.c + $3.c + ">"; }
  | E IGU E       { $$.c = $1.c + $3.c + "=="; }
  | E DIF E        { $$.c = $1.c + $3.c + "!="; }
  | E ADD E        { $$.c = $1.c + $3.c + "+"; }
  | E SUB E       { $$.c = $1.c + $3.c + "-"; }
  | E MUL E        { $$.c = $1.c + $3.c + "*"; }
  | E DIV E         { $$.c = $1.c + $3.c + "/"; }
  | SUB E         { $$.c = "0" + $2.c + "-"; }
  | F                  { $$ = $1; }
  ;
  

F : ID          { $$.c = $1.c + "@"; }
  | NUM         { $$.c = $1.c; }
  | STRING         { $$.c = $1.c; }
  | '(' E ')'      { $$ = $2; }
  | OBJ     { string temp = "{}";$$.c = atr + temp; }
  | '[' ']'       { $$.c = atr + "[]"; }
  ;

%%

#include "lex.yy.c"

void print(vector<string> str){
  cout << "Tamanho da string encontrada: " << str.size() << endl;
  for(int i = 0; i < str.size();i++){
    cout << str[i] << endl;
  }
  //cout << '.' << endl;
}

vector<string> concatena( vector<string> a, vector<string> b ) {
  a.insert( a.end(), b.begin(), b.end() );
  return a;
}

vector<string> operator+( vector<string> a, vector<string> b ) {
  return concatena( a, b );
}

vector<string> operator+(vector<string> a, string b) {
  a.push_back(b);
  return a;
}

vector<string> operator+(string a, vector<string> b) {
  vector<string> c;
  c.push_back(a);
  return c + b;
}

string gera_label( string prefixo ) {
  static int n = 0;
  return prefixo + "_" + to_string( ++n ) + ":";
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;
  for( int i = 0; i < entrada.size(); i++ ) 
    if( entrada[i][0] == ':' ) 
        label[entrada[i].substr(1)] = saida.size();
    else
      saida.push_back( entrada[i] );
  
  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

int tokeniza(int token) {
    yylval.c = atr + yytext;
    coluna += strlen(yytext);
    yylval.l = linha;
    return token;
}

void yyerror( const char* st ) {
   puts( st ); 
   printf( "Proximo a: %s\n na linha: %d e coluna: %d\n", yytext, linha, coluna );
   exit( 1 );
}

int main( int argc, char* argv[] ) {
  yyparse();
  
  return 0;
}