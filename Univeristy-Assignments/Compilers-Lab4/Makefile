# lab4/Makefile

all: ppc

TOOLS = ../tools

ppc: util.cmo mach.cmo optree.cmo dict.cmo tree.cmo lexer.cmo \
		parser.cmo check.cmo target.cmo regs.cmo simp.cmo \
		share.cmo jumpopt.cmo tran.cmo tgen.cmo main.cmo
	ocamlc -g ../lib/common.cma $^ -o $@ 

parser.ml parser.mli: parser.mly
	ocamlyacc -v parser.mly

lexer.ml: lexer.mll
	ocamllex lexer.mll

%.cmi: %.mli
	ocamlc $(MLFLAGS) -c -g $<

%.cmo: %.ml $(TOOLS)/nodexp
	ocamlc $(MLFLAGS) -c -g -pp $(TOOLS)/nodexp $<

MLFLAGS = -I ../lib

$(TOOLS)/nodexp $(TOOLS)/pibake: $(TOOLS)/%: 
	$(MAKE) -C $(TOOLS) $*

test: force
	@echo "Say..."
	@echo "  'make test0' to compare assembly code"
	@echo "  'make test1' to test using QEMU"
	@echo "  'make test2' to test using a remote RPi"
	@echo "  'make test3' to test using ECSLAB remotely"

TESTSRC := $(shell ls test/*.p)
OPT = -O2

SCRIPT1 = -e '1,/^(\*\[\[/d' -e '/^]]\*)/q' -e p
SCRIPT2 = -e '1,/^(\*<</d' -e '/^>>\*)/q' -e p

ARMGCC = arm-linux-gnueabihf-gcc -marm -march=armv6

ARCH := $(shell uname -m)
QEMU-armv6l = env
QEMU-armv7l = env
QEMU := $(QEMU-$(ARCH))
ifndef QEMU
    QEMU := qemu-arm
endif

# test0 -- compile tests and diff object code
test0 : $(TESTSRC:test/%.p=test0-%)

test0-%: force
	@echo "*** Test $*.p"
	./ppc $(OPT) test/$*.p >b.s
	-sed -n $(SCRIPT1) test/$*.p | diff -u -b - b.s
	@echo

# test1 -- compile tests and execute with QEMU
test1 : $(TESTSRC:test/%.p=test1-%)

test1-%: pas0.o force
	@echo "*** Test $*.p"
	./ppc $(OPT) test/$*.p >b.s
	$(ARMGCC) b.s pas0.o -static -o b.out 
	$(QEMU) ./b.out >b.test
	sed -n $(SCRIPT2) test/$*.p | diff - b.test
	@echo "*** Passed"; echo

pas0.o: pas0.c
	$(ARMGCC) -c $< -o $@

# test2 -- compile tests and execute using remote or local RPi
test2 : $(TESTSRC:test/%.p=test2-%)

test2-%: $(TOOLS)/pibake force
	@echo "*** Test $*.p"
	./ppc $(OPT) test/$*.p >b.s
	$(TOOLS)/pibake b.s >b.test
	sed -n $(SCRIPT2) test/$*.p | diff - b.test
	@echo "*** Passed"; echo

# test3 -- ditto but using qemu on ecs.ox
test3 : $(TESTSRC:test/%.p=test3-%)

test3-%: $(TOOLS)/ecsx force
	@echo "*** Test $*.p"
	./ppc $(OPT) test/$*.p >b.s
	$(TOOLS)/ecsx pas0.c fixup.s b.s >b.test
	sed -n $(SCRIPT2) test/$*.p | diff - b.test
	@echo "*** Passed"; echo

promote: $(TESTSRC:test/%.p=promote-%)

promote-%: force
	./ppc $(OPT) test/$*.p >b.s
	sed -f promote.sed test/$*.p >test/$*.new
	mv test/$*.new test/$*.p

force:

MLGEN = parser.mli parser.ml lexer.ml

ML = $(MLGEN) optree.ml tgen.ml tran.ml simp.ml share.ml jumpopt.ml \
	check.ml check.mli dict.ml dict.mli lexer.mli \
	mach.ml mach.mli main.ml optree.mli tgen.mli tree.ml \
	tree.mli util.ml tran.mli target.mli target.ml \
	simp.mli share.mli regs.mli regs.ml jumpopt.mli

clean: force
	rm -f *.cmi *.cmo *.o *.output
	rm -f $(MLGEN)
	rm -f ppc b.out b.s b.test

depend: $(ML) $(TOOLS)/nodexp force
	(sed '/^###/q' Makefile; echo; ocamldep -pp $(TOOLS)/nodexp $(ML)) >new
	mv new Makefile

CC = gcc

###

parser.cmi : tree.cmi optree.cmi dict.cmi
parser.cmo : tree.cmi optree.cmi lexer.cmi dict.cmi parser.cmi
parser.cmx : tree.cmx optree.cmx lexer.cmx dict.cmx parser.cmi
lexer.cmo : util.cmo parser.cmi optree.cmi dict.cmi lexer.cmi
lexer.cmx : util.cmx parser.cmx optree.cmx dict.cmx lexer.cmi
optree.cmo : optree.cmi
optree.cmx : optree.cmi
tgen.cmo : tree.cmi tran.cmi target.cmi simp.cmi share.cmi regs.cmi \
    optree.cmi mach.cmi lexer.cmi jumpopt.cmi dict.cmi tgen.cmi
tgen.cmx : tree.cmx tran.cmx target.cmx simp.cmx share.cmx regs.cmx \
    optree.cmx mach.cmx lexer.cmx jumpopt.cmx dict.cmx tgen.cmi
tran.cmo : target.cmi regs.cmi optree.cmi tran.cmi
tran.cmx : target.cmx regs.cmx optree.cmx tran.cmi
simp.cmo : util.cmo optree.cmi simp.cmi
simp.cmx : util.cmx optree.cmx simp.cmi
share.cmo : regs.cmi optree.cmi mach.cmi share.cmi
share.cmx : regs.cmx optree.cmx mach.cmx share.cmi
jumpopt.cmo : util.cmo optree.cmi jumpopt.cmi
jumpopt.cmx : util.cmx optree.cmx jumpopt.cmi
check.cmo : util.cmo tree.cmi optree.cmi mach.cmi lexer.cmi dict.cmi \
    check.cmi
check.cmx : util.cmx tree.cmx optree.cmx mach.cmx lexer.cmx dict.cmx \
    check.cmi
check.cmi : tree.cmi
dict.cmo : util.cmo optree.cmi mach.cmi dict.cmi
dict.cmx : util.cmx optree.cmx mach.cmx dict.cmi
dict.cmi : optree.cmi mach.cmi
lexer.cmi : parser.cmi optree.cmi dict.cmi
mach.cmo : mach.cmi
mach.cmx : mach.cmi
mach.cmi :
main.cmo : tree.cmi tran.cmi tgen.cmi parser.cmi mach.cmi lexer.cmi \
    check.cmi
main.cmx : tree.cmx tran.cmx tgen.cmx parser.cmx mach.cmx lexer.cmx \
    check.cmx
optree.cmi :
tgen.cmi : tree.cmi
tree.cmo : optree.cmi dict.cmi tree.cmi
tree.cmx : optree.cmx dict.cmx tree.cmi
tree.cmi : optree.cmi dict.cmi
util.cmo :
util.cmx :
tran.cmi : optree.cmi
target.cmi : optree.cmi
target.cmo : optree.cmi target.cmi
target.cmx : optree.cmx target.cmi
simp.cmi : optree.cmi
share.cmi : optree.cmi
regs.cmi : target.cmi
regs.cmo : util.cmo target.cmi regs.cmi
regs.cmx : util.cmx target.cmx regs.cmi
jumpopt.cmi : optree.cmi
