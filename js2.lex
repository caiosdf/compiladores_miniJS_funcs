DIGITO  [0-9]
LETRA   [A-Za-z_]
NUM     {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
STRING     (\"([^\"\n]|(\\\")|\"\")+\")|(\'([^\'\n]|(\\\')|\'\')+\')

%%

"\t"       { coluna += 4; }
" "        { coluna++; }
"\n"       { linha++; coluna = 1; }

{NUM}      { return tokeniza(NUM); }
"+="       { return tokeniza(ADD_IGU); }
"++"       { return tokeniza(ADD_ADD); }
"+"        { return tokeniza(ADD); }
"-"        { return tokeniza(SUB); }
"*"        { return tokeniza(MUL); }
"/"        { return tokeniza(DIV); }
"<="       { return tokeniza(MEG); }
">="       { return tokeniza(MAG); }
"<"        { return tokeniza(MEN); }
">"        { return tokeniza(MAI); }
"=="       { return tokeniza(IGU); }
"!="       { return tokeniza(DIF); }
"if"       { return tokeniza(IF); }
"else"     { return tokeniza(ELSE); }
"while"    { return tokeniza(WHILE); }
"for"      { return tokeniza(FOR); }
"let"	   { return tokeniza(LET); }
"function" { return tokeniza(FUNCTION); }
"[]"       { return tokeniza(ARR); }
"{}"       { return tokeniza(OBJ); }
{STRING}      { return tokeniza(STRING); }
{ID}       { return tokeniza(ID); }
.          { return tokeniza(*yytext); }

%%