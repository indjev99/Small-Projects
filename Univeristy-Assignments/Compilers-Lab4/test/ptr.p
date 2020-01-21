(* Pointer-linked trees *)

type 
  tree = pointer to node;
  node = record left, right: tree end;

proc build(n: integer): tree;
  var t: tree;
begin
  if n <= 1 then
    return nil
  else
    new(t);
    t^.left := build(n-2);
    t^.right := build(n-1);
    return t
  end
end;

proc print(t: tree);
  var tt: tree;
begin
  tt := t;
  if tt = nil then
    print_char('.')
  else
    print_char('(');
    print(tt^.left);
    print(tt^.right);
    print_char(')')
  end
end;

proc count(t: tree): integer;
  var tt: tree;
begin
  tt := t;
  if tt = nil then
    return 1
  else
    return count(tt^.left) + count(tt^.right)
  end
end;

var n: integer; p: tree;

begin 
  for n := 0 to 7 do
    p := build(n);
    print_num(count(p)); print_char(' ');
    print(p); newline()
  end
end.

(*<<
1 .
1 .
2 (..)
3 (.(..))
5 ((..)(.(..)))
8 ((.(..))((..)(.(..))))
13 (((..)(.(..)))((.(..))((..)(.(..)))))
21 (((.(..))((..)(.(..))))(((..)(.(..)))((.(..))((..)(.(..))))))
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc build(n: integer): tree;
	.text
_build:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if n <= 1 then
	ldr r0, [fp, #40]
	cmp r0, #1
	bgt .L3
@     return nil
	mov r0, #0
	b .L1
.L3:
@     new(t);
	mov r0, #8
	bl new
	mov r4, r0
@     t^.left := build(n-2);
	ldr r0, [fp, #40]
	sub r0, r0, #2
	bl _build
	str r0, [r4]
@     t^.right := build(n-1);
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _build
	str r0, [r4, #4]
@     return t
	mov r0, r4
.L1:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc print(t: tree);
_print:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   tt := t;
	ldr r4, [fp, #40]
@   if tt = nil then
	cmp r4, #0
	bne .L7
@     print_char('.')
	mov r0, #46
	bl print_char
	b .L5
.L7:
@     print_char('(');
	mov r0, #40
	bl print_char
@     print(tt^.left);
	ldr r0, [r4]
	bl _print
@     print(tt^.right);
	ldr r0, [r4, #4]
	bl _print
@     print_char(')')
	mov r0, #41
	bl print_char
.L5:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc count(t: tree): integer;
_count:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   tt := t;
	ldr r4, [fp, #40]
@   if tt = nil then
	cmp r4, #0
	bne .L11
@     return 1
	mov r0, #1
	b .L9
.L11:
@     return count(tt^.left) + count(tt^.right)
	ldr r0, [r4]
	bl _count
	mov r5, r0
	ldr r0, [r4, #4]
	bl _count
	add r0, r5, r0
.L9:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   for n := 0 to 7 do
	mov r0, #0
	set r1, _n
	str r0, [r1]
	mov r4, #7
.L14:
	set r0, _n
	ldr r5, [r0]
	cmp r5, r4
	bgt .L13
@     p := build(n);
	mov r0, r5
	bl _build
	set r1, _p
	str r0, [r1]
@     print_num(count(p)); print_char(' ');
	bl _count
	bl print_num
	mov r0, #32
	bl print_char
@     print(p); newline()
	set r0, _p
	ldr r0, [r0]
	bl _print
	bl newline
	set r5, _n
	ldr r0, [r5]
	add r0, r0, #1
	str r0, [r5]
	b .L14
.L13:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _n, 4, 4
	.comm _p, 4, 4
@ End
]]*)
