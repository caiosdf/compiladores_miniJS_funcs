%{
    void posicao();
%}
WS          [ \n\t\r]
DIGITO  [0-9]
LETRA   [A-Za-z_]
NUM  {DIGITO}+("."{DIGITO}+)?
ID      {LETRA}({LETRA}|{DIGITO})*
ASPAS_DUPLAS    (\"((\"{2})*(\\.|[^"\\\n])*)*\")
ASPAS_SIMPLES   (\'((\'{2})*(\\.|[^'\\\n])*)*\')
STRING  {ASPAS_SIMPLES}|{ASPAS_DUPLAS}

%%

"\n"/{WS}*({ID}|{NUM})*{WS}* { linha++; coluna = 1;
                              if(ultimo_token != ';'){
                                  //ultimo_token = ';';
                                  return FIM_DE_LINHA;
                              }
                            }

"\t"       { posicao(); }
" "        { posicao(); }
"\n"	   { posicao(); }

             
{NUM}   { 
            posicao(); 
            yylval.c = yytext; 
            //ultimo_token = 'NUM'; 
            return NUM; 
        }

"let"	   { 
                posicao(); 
                yylval.c = ""; 
                // ultimo_token = 'LET'; 
                return LET; 
            }
"if"        { 
                posicao(); 
                //ultimo_token = 'IF'; 
                return IF; 
            }
"for"        { 
                posicao(); 
                //ultimo_token = 'FOR'; 
                return FOR; 
            }
"while"        { 
                    posicao(); 
                    //ultimo_token = 'WHILE'; 
                    return WHILE; 
                }


{STRING}       { 
                    posicao(); 
                    yylval.c = yytext; 
                    //ultimo_token = 'STRING'; 
                    return STRING; 
                }

"-"         { 
                posicao(); 
                //ultimo_token = 'SUB'; 
                return SUB; 
            }
"+"         { 
                posicao(); 
                //ultimo_token = 'ADD'; 
                return ADD; 
            }
"*"         { 
                posicao(); 
                //ultimo_token = 'MUL'; 
                return MUL; 
            }
"/"         { 
                posicao(); 
                //ultimo_token = 'DIV'; 
                return DIV; 
            }
"<"         { 
                posicao(); 
                //ultimo_token = 'MEN'; 
                return MEN; 
            }
">"         { 
                posicao(); 
                //ultimo_token = 'MAI'; 
                return MAI;
            }
"<="        { 
                posicao();
                //ultimo_token = 'MEG'; 
                return MEG; 
            }
">="        { 
                posicao(); 
                //ultimo_token = 'MAG'; 
                return MAG; 
            }
"=="        { 
                posicao(); 
                //ultimo_token = 'IGU'; 
                return IGU; 
            }
"!="        { 
                posicao(); 
                //ultimo_token = 'DIF'; 
                return DIF; 
            }

{ID}       { 
                posicao(); 
                yylval.c = yytext; 
                //ultimo_token = 'ID'; 
                return ID; 
            }

.          { yylval.c = yytext;
	     return yytext[0]; }

%%

void posicao() {
  int i;
  for (i = 0; yytext[i] != '\0'; i++) {
    if (yytext[i] == '\n') {
      coluna = 1;
      linha++;
    } else if (yytext[i] == '\t'){
        coluna += 4;
    } else {
      coluna++;
    }
  }
}