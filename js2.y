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
  vector<string> a;
  vector<string> i;
  vector<string> pos_action;

  int l;
};

#define YYSTYPE Atributos

int yylex();
int yyparse();
void yyerror(const char *);
void print(vector<string> str);
vector<string> concatena( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, vector<string> b );
vector<string> operator+(string a, vector<string> b);
vector<string> operator+(vector<string> a, string b);
string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );
int tokeniza(int token);
void var_existe(Atributos var);
void declara_var(Atributos var);

vector<string> atr;
vector<string> funcoes;
map<string,int> vars;
int linha = 1, coluna = 1, nARGS = 0, nPARAMS = 0;


%}

%token FUNCTION IF ELSE NUM ID LET WHILE FOR STRING ARR ADD ADD_IGU ADD_ADD SUB MUL DIV MOD MAI MEN MEG MAG IGU DIF OBJ

%left MAI MEN MEG MAG IGU DIF 
%left ADD_ADD
%left ADD SUB ADD_IGU 
%left MUL DIV

%start S // simbolo inicial da gramatica

%%

S : CMDs  { $$.c = $1.c + "." + funcoes; print( resolve_enderecos($$.c) ); }
  ;

CMDs : CMD ';' CMDs         { $$.c = $1.c + "\n" + $3.c; }
     | CHAMADA_BLOCO        
     |                      { $$.c = atr; }
     ;

CMD : RVALUE                     { $$.c = $1.c + "^"; }
    | LET DECLVARS          { $$ = $2; }             
    ;

CHAMADA_BLOCO : IF_BLOCO
              | WHILE_BLOCO
              | FOR_BLOCO
              ;

FOR_BLOCO : FOR '(' CMD ';' E ';' RVALUE ')' BLOCO {
    string ini_for = gera_label("begin_for");
    string fim_for = gera_label("end_for");
    $$.c = $3.c + (":" + ini_for) + $5.c + "!" + fim_for + "?" + $9.c + $7.c + "^" + ini_for + "#" + (":" + fim_for);
}

WHILE_BLOCO : WHILE '(' E ')' BLOCO CMDs {
    string ini_while = gera_label("ini_while");
    string fim_while = gera_label("fim_while");
    $$.c = (":" + ini_while) + $3.c + "!" + fim_while + "?" + $5.c + ini_while + "#" + (":" + fim_while) + $6.c;
}

IF_BLOCO : IF '(' RVALUE ')' IF_CORPO ELSE_IF_ST ELSE_ST CMDs{
    if($6.c.size() == 0 && $7.c.size() == 0){
        string end_if = gera_label("end_if");
        $$.c = $3.c + " ! " + end_if + " ? " + $5.c + (":" + end_if) + $8.c; 
    } else {
        string ini_if = gera_label("ini_if");
        string teste_else_if = gera_label("teste_else_if");
        string ini_else_if = gera_label("ini_else_if");
        string ini_else = gera_label("ini_else");
        string fim_else = gera_label("fim_else");
        $$.c = $3.c + ini_if + "?" + teste_else_if + "#" + (":" + ini_if) + $5.c + fim_else + "#" + (":" + teste_else_if) + $6.a + ini_else_if + "?" + ini_else + "#" + (":" + ini_else_if) + $6.c + fim_else + "#" + (":" + ini_else) + $7.c + (":" + fim_else) + $8.c ;
    }
}
        ;

IF_CORPO : BLOCO
         | CMD ';'
         | CMD
         ;


BLOCO : '{' CMDs '}'        { $$.c = $2.c; }
      | '{' CMDs '}' ';'    { $$.c = $2.c; }
      ;

ELSE_IF_ST : ELSE IF '(' E ')' BLOCO { $$.c = $6.c; $$.a = $4.c; }
           |                         { $$.c = atr; }
           ;

ELSE_ST : ELSE_BLOCO
        | ELSE_LINHA
        | ELSE               { $$.c = atr; }
        |                     
        ;

ELSE_BLOCO : ELSE BLOCO { $$.c = $2.c; }
           ;
           

ELSE_LINHA : ELSE CMD ';' CMDs  { $$.c = $2.c + $4.c; }
           ;
           
ARGs : E ',' ARGs { $$.c = $1.c + $3.c; nARGS++;}
     | E          { $$.c = $1.c; nARGS++; }
     |            { $$.c = atr; }
     ;

FUNC_CHAMADA : LVALUE '(' ARGs ')' {
  $$.c = $3.c + to_string(nARGS) + $1.c + "@" + "$";
  nARGS = 0;
} 
             ;

PARAMS : LVALUE ',' PARAMS { $$.c = $1.c + $3.c; nPARAMS++;}
       | LVALUE          { $$.c = $1.c; nPARAMS++; }
       |            { $$.c = atr; }
       ;

FUNC_DECL : FUNCTION LVALUE '(' PARAMS ')' BLOCO {
  {
    string ini_func = gera_label("ini_func");
    $$.c = $2.c + "&" + $2.c + "{}" + "=" + "'&funcao'" + ini_func + "[=]" + "^";    
    funcoes.push_back(":" + ini_func);
    for(int i = 0; i < nPARAMS; i++){
      vector<string> tmp = {argList.at(nPARAMS-i-1), "&", argList.at(nPARAMS-i-1), "arguments", "@", to_string(i), "[@]", "=", "^"};
      funcSource.insert(funcSource.end(), tmp.begin(), tmp.end());
    }
    
    // inserindo bloco na string list
    funcSource.insert(funcSource.end(), $6.c.begin(), $6.c.end());
    
    // retorno final de undefined
    vector<string> finalReturn = {"undefined", "@", "'&retorno'", "@", "~"};
    funcSource.insert(funcSource.end(), finalReturn.begin(), finalReturn.end());
    
    argCounter = 0; argList.clear(); is_function_scope = false;
  }
}
          ;

DECLVARS : DECLVAR ',' DECLVARS  { $$.c = $1.c + $3.c; }
         | DECLVAR
         ;

DECLVAR : ID '=' RVALUE  { declara_var($1);$$.c = $1.c + "&" + $1.c + " " + $3.c + "=" + "^"; }
        | ID        { declara_var($1);$$.c = $1.c + "&"; }
        ;

A : LVALUE '=' RVALUE { var_existe($1); $$.c = $1.c + " " + $3.c + "="; }
  | LVALUE ADD_IGU RVALUE { $$.c = $1.c + " " + $1.c + "@ " + $3.c + "+" + "="; }
  | LVALUEPROP '=' RVALUE { $$.c = $1.c + $1.i + $3.c + "[=]"; }  
  | LVALUEPROP ADD_IGU RVALUE { $$.c = $1.c + $1.i + " " + $1.c + $1.i + "[@]" + $3.c + "+" + "[=]"; }                   
  ;

LVALUEPROP : E '.' ID    { $$.c = $1.c + $3.c; }
           | E '[' RVALUE ']' { $$.c = $1.c; $$.i = $3.c; }
           ;

RVALUE : E {
    if($$.pos_action.size() == 0){
        $$.c = $1.c;
    } else {
        $$.c = $1.c + $1.pos_action;
    }
}
       | A
       ;

E : E MEG E        { $$.c = $1.c + " " + $3.c + "<="; }
  | E MAG E        { $$.c = $1.c + " " + $3.c + ">="; }
  |	E MEN E       { $$.c = $1.c + " " + $3.c + "<"; }
  | E MAI E       { $$.c = $1.c + " " + $3.c + ">"; }
  | E IGU E       { $$.c = $1.c + " " + $3.c + "=="; }
  | E DIF E        { $$.c = $1.c + " " + $3.c + "!="; }
  | E ADD E        { $$.c = $1.c + " " + $3.c + "+"; }
  | E SUB E       { $$.c = $1.c + " " + $3.c + "-"; }
  | E MUL E        { $$.c = $1.c + " " + $3.c + "*"; }
  | E DIV E         { $$.c = $1.c + " " + $3.c + "/"; }
  | SUB E         { $$.c = "0 " + $2.c + " -"; }
  | LVALUE ADD_ADD     { $$.c = $1.c + "@"; $$.pos_action = $1.c + " " + $1.c + "@" + "1" + "+" + "=" + "^"; }
  | F                  { $$ = $1; }
  ;
  
LVALUE : ID
       ;

F : OBJ
  | ARR
  | LVALUE          { $$.c = $1.c + "@"; }
  | LVALUEPROP      { $$.c = $1.c + "[@]"; }
  | NUM             { $$.c = $1.c; }
  | STRING          { $$.c = $1.c; }
  | '(' RVALUE ')'  { $$.c = $2.c; }
  | FUNC_CHAMADA   
  ;

%%

#include "lex.yy.c"

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

void declara_var(Atributos var) {
    if(vars.count(var.c.back()) == 0){
        vars[var.c.back()] = var.l;
    } else {
        cout << "Erro: a variável '" << var.c.back() << "' já foi declarada na linha " << vars[var.c.back()] << "." << endl;
	    exit(1);
    }
}

void var_existe(Atributos var){
    if(vars.count(var.c.back()) == 0){
        cout << "Erro: a variável '" << var.c.back() << "' não foi declarada." << endl;
        exit(1);
    }
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;
  vector<string> tmp;

  for( int i = 0; i < entrada.size(); i++ ) {
    if( entrada[i] != " " && entrada[i] != "\n"){
        tmp.push_back( entrada[i] );
    }
  }

  for( int i = 0; i < tmp.size(); i++ ) 
    if( tmp[i][0] == ':' ) 
        label[tmp[i].substr(1)] = saida.size();
    else
      saida.push_back( tmp[i] );

  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

void print(vector<string> str){
  for(int i = 0; i < str.size();i++){
    cout << str[i] << " ";
  }
  cout << '.' << endl;
}

void yyerror( const char* st ) {
   puts( st ); 
   printf( "Proximo a: %s, linha: %d, coluna: %d\n", yytext, linha, coluna);
   exit( 1 );
}

int tokeniza(int token) {
    coluna += strlen(yytext);
    yylval.c = atr + yytext;
    yylval.l = linha;
    return token;
}

int main( int argc, char** argv ) {
  yyparse();
  return 0;
}