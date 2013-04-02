lexec: lex.yy.c
	gcc -o lexec lex.yy.c -lfl

lex.yy.c: lex.l
	lex lex.l

lexbi: lex.yy.c y.tab.c
	gcc -o lexbixec lex.yy.c y.tab.c -lfl -lm `pkg-config --cflags --libs cairo`

lexbee: lex.yy.c y.tab.c
	gcc -o lexbixec lex.yy.c y.tab.c -lfl -lm -lpixman-1 `pkg-config --cflags --libs cairo`

y.tab.c:
	bison -d -y bi.y

clean:
	rm -f lexec lexbixec lex.yy.c y.tab.c y.tab.h