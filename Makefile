lexec: lex.yy.c
	gcc -o lexec lex.yy.c -lfl
lex.yy.c: lex.l
	lex lex.l

lexbi: lex.yy.c bi.tab.c
	gcc -o lexbixec lex.yy.c bi.tab.c -lfl
bi.tab.c:
	bison -d -o bi.tab.c bi.y

clean:
	rm -f lexec lexbixec lex.yy.c bi.tab.c bi.tab.h