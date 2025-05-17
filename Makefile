.PHONY: all
all: parser.h lex.yy.c gerber

gerber: src/main.cpp \
		src/ast_node.c \
		src/svg.c \
		parser.c \
		lex.yy.c
		g++ -g -o gerber \
		src/main.cpp \
		src/ast_node.c \
		src/svg.c \
		parser.c \
		lex.yy.c -I ./ -I ./src

lex.yy.c: grammar/lexer.l
	flex -d grammar/lexer.l

parser.h: grammar/parser.y
	bison -v --defines=parser.h --output=parser.c grammar/parser.y

.PHONY: clean

clean:
	rm -f gerber.exe parser.h parser.c lex.yy.c build/parser.output