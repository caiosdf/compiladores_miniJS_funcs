all: js entrada.txt
	./js < entrada.txt

lex.yy.c: js.lex
	lex js.lex

y.tab.c: js.y
	yacc js.y

js: lex.yy.c y.tab.c
	g++ -o js y.tab.c -ll