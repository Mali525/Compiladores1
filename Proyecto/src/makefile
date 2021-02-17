input      = ../test/one.c-- "one_code.txt"

readme     = README.md
flex       = lexer.flex
flex_c     = lex.yy.c
flex_o     = flex.o
tokens     = tokens.h
prev_bison = gram.y
orig_bison = ./semantic/*.*
dir_bison  = ./semantic
bison      = semantic.y
bison_c    = semantic.tab.c
bison_o    = bison.o
compiler   = compiler.cpp
compiler_o = compiler.o
outs       = $(flex_o) $(bison_o) $(compiler_o) *.cc
executable = g--
this       = makefile

all: run

run: build
	./$(executable) $(input)

build:
	cp $(orig_bison) .
	flex -o $(flex_c) $(flex)
	bison -o $(bison_c) -d $(bison)
	g++ -c $(flex_c)    -o $(flex_o)
	g++ -c $(bison_c)   -o $(bison_o)
	g++ -c $(compiler)  -o $(compiler_o)
	g++ $(outs)         -o $(executable) -lfl -g3

clean:
	mkdir -p temp
	cp $(readme) temp
	cp $(flex) temp
	cp $(tokens) temp
	cp -R $(dir_bison) temp
	cp $(prev_bison) temp