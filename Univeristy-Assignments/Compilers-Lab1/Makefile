# lab1/Makefile

## Add your own test cases to this list
TEST = gcd repeat loop case

all: ppc

ppc: keiko.cmo lexer.cmo tree.cmo parser.cmo peepopt.cmo kgen.cmo main.cmo
	ocamlc ../lib/common.cma $^ -o $@ 

parser.mli parser.ml: parser.mly
	ocamlyacc -v parser.mly

lexer.ml: lexer.mll
	ocamllex lexer.mll

tree.cmo: MLFLAGS += -w u

KEIKO = ../keiko

test : force
	$(MAKE) $(TEST:%=test-%)

test-%: force
	@echo "*** Test $*.p"
	./ppc $*.p >a.k
	$(KEIKO)/pplink -nostdlib $(KEIKO)/lib.k a.k -o a.x >/dev/null
	$(KEIKO)/ppx ./a.x >a.test
	sed -n -e '1,/^(\*<</d' -e '/^>>\*)/q' -e p $*.p | diff - a.test
	@echo "*** Passed"; echo

realclean: clean

clean: force
	rm -f ppc *.cma *.cmo *.cmi
	rm -f parser.mli parser.ml lexer.ml parser.output
	rm -f a.k a.out a.x a.test

ML = keiko.ml keiko.mli kgen.ml kgen.mli lexer.mli \
	lexer.ml main.ml parser.mli parser.ml tree.ml tree.mli \
	peepopt.mli peepopt.ml

depend : $(ML) force
	(sed '/^###/q' Makefile; echo; ocamldep $(ML)) >new
	mv new Makefile

%.cmi : %.mli
	ocamlc $(MLFLAGS) -c $<

%.cmo : %.ml
	ocamlc $(MLFLAGS) -c $<

force:

MLFLAGS = -I ../lib

###

keiko.cmo : tree.cmi keiko.cmi
keiko.cmx : tree.cmx keiko.cmi
keiko.cmi :
kgen.cmo : tree.cmi peepopt.cmi keiko.cmi kgen.cmi
kgen.cmx : tree.cmx peepopt.cmx keiko.cmx kgen.cmi
kgen.cmi : tree.cmi
lexer.cmo : tree.cmi parser.cmi keiko.cmi lexer.cmi
lexer.cmx : tree.cmx parser.cmx keiko.cmx lexer.cmi
lexer.cmi : tree.cmi parser.cmi
main.cmo : tree.cmi parser.cmi lexer.cmi kgen.cmi
main.cmx : tree.cmx parser.cmx lexer.cmx kgen.cmx
parser.cmo : tree.cmi lexer.cmi keiko.cmi parser.cmi
parser.cmx : tree.cmx lexer.cmx keiko.cmx parser.cmi
parser.cmi : tree.cmi keiko.cmi
peepopt.cmo : keiko.cmi peepopt.cmi
peepopt.cmx : keiko.cmx peepopt.cmi
peepopt.cmi : keiko.cmi
tree.cmo : keiko.cmi tree.cmi
tree.cmx : keiko.cmx tree.cmi
tree.cmi : keiko.cmi
