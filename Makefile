all: lexbi spirale testRotate testTranslate

spirale: spirale.c
	gcc -o spirale spirale.c

testRotate: testRotate.c
	gcc -o testRotate testRotate.c

testTranslate: testTranslate.c
	gcc -o testTranslate testTranslate.c
	cp testTranslate papillon

lex.yy.c: lex.l
	lex lex.l

lexbi: lex.yy.c y.tab.c
	gcc -g -o lexbixec lex.yy.c y.tab.c -lfl -lm `pkg-config --cflags --libs cairo`

lexbee: lex.yy.c y.tab.c
	gcc -g -o lexbixec lex.yy.c y.tab.c -lfl -lm -lpixman-1 `pkg-config --cflags --libs cairo`

y.tab.c:
	bison -d -y bi.y

clean:
	rm -f lexec lexbixec lex.yy.c y.tab.c y.tab.h testRotate testTranslate papillon spirale
