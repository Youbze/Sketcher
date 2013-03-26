lexec: lex.yy.c
	gcc -o lexec lex.yy.c -lfl
lex.yy.c: lex.l
	lex lex.l

lexbi: lex.yy.c y.tab.c
	gcc -o lexbixec lex.yy.c y.tab.c -lfl
y.tab.c:
	bison -d -y bi.y

clean:
	rm -f lexec lexbixec lex.yy.c y.tab.c y.tab.h