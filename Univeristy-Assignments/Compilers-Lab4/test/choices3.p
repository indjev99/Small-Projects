(* Enumerate (n choose k) choices with linked list *)

const letters = "abcdef";

type list = pointer to cell; cell = record head: char; tail: list end;

proc cons(head: char; tail: list): list;
  var p: list;
begin
  new(p);
  p^.head := head; p^.tail := tail;
  return p
end;

proc print(p: list);
  var q: list;
begin
  q := p;
  while q <> nil do
    print_char(q^.head);
    q := q^.tail
  end
end;

(* Complete choice with k items chosen from [0..n) *)
proc choose(k, n: integer; suffix: list);
begin
  if k <= n then
    if k = 0 then
      print(suffix); newline()
    else
      choose(k, n-1, suffix);
      choose(k-1, n-1, cons(letters[n-1], suffix))
    end
  end
end;

begin
  choose(3, 6, nil)
end.    

(*<<
abc
abd
acd
bcd
abe
ace
bce
ade
bde
cde
abf
acf
bcf
adf
bdf
cdf
aef
bef
cef
def
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc cons(head: char; tail: list): list;
	.text
_cons:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   new(p);
	mov r0, #8
	bl new
	mov r4, r0
@   p^.head := head; p^.tail := tail;
	ldrb r0, [fp, #40]
	strb r0, [r4]
	ldr r0, [fp, #44]
	str r0, [r4, #4]
@   return p
	mov r0, r4
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc print(p: list);
_print:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   q := p;
	ldr r4, [fp, #40]
.L4:
@   while q <> nil do
	cmp r4, #0
	beq .L3
@     print_char(q^.head);
	ldrb r0, [r4]
	bl print_char
@     q := q^.tail
	ldr r4, [r4, #4]
	b .L4
.L3:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc choose(k, n: integer; suffix: list);
_choose:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if k <= n then
	ldr r4, [fp, #40]
	ldr r0, [fp, #44]
	cmp r4, r0
	bgt .L7
@     if k = 0 then
	cmp r4, #0
	bne .L12
@       print(suffix); newline()
	ldr r0, [fp, #48]
	bl _print
	bl newline
	b .L7
.L12:
@       choose(k, n-1, suffix);
	ldr r2, [fp, #48]
	ldr r0, [fp, #44]
	sub r1, r0, #1
	ldr r0, [fp, #40]
	bl _choose
@       choose(k-1, n-1, cons(letters[n-1], suffix))
	ldr r4, [fp, #44]
	ldr r1, [fp, #48]
	set r0, g1
	add r0, r0, r4
	ldrb r0, [r0, #-1]
	bl _cons
	mov r2, r0
	sub r1, r4, #1
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _choose
.L7:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   choose(3, 6, nil)
	mov r2, #0
	mov r1, #6
	mov r0, #3
	bl _choose
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.data
g1:
	.byte 97, 98, 99, 100, 101, 102
	.byte 0
@ End
]]*)
