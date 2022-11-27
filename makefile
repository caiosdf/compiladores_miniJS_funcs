all: js entrada.txt
	./js < entrada.txt

lex.yy.c: js2.lex
	lex js2.lex

y.tab.c: js2.y
	yacc js2.y

js: lex.yy.c y.tab.c
	g++ -o js y.tab.c -ll