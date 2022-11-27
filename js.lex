DIGITO  [0-9]
LETRA   [A-Za-z_]
NUM  {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
STRING  \"([^"\n]|\"\"|\\\")*\"

%%

"\t"       { coluna += 4; }
" "        { linha++; coluna = 1; }
"\n"	   { coluna++; }

             
{NUM}           { tokeniza(NUM); }
"let"	        { tokeniza(LET); }
"if"            { tokeniza(IF); }
"for"           { tokeniza(FOR); }
"while"         { tokeniza(WHILE); }
"-"             { tokeniza(SUB); }
"+"             { tokeniza(ADD); }
"*"             { tokeniza(MUL); }
"/"             { tokeniza(DIV); }
"<"             { tokeniza(MEN); }
">"             { tokeniza(MAI); }
"<="            { tokeniza(MEG); }
">="            { tokeniza(MAG); }
"=="            { tokeniza(IGU); }
"!="            { tokeniza(DIF); }
"%"             { tokeniza(MOD); }
"{}"            { tokeniza(OBJ); }
"[]"            { tokeniza(ARR); }
{STRING}        { tokeniza(STRING); }
{ID}            { tokeniza(ID); }
.               { tokeniza(*yytext);}

%%

