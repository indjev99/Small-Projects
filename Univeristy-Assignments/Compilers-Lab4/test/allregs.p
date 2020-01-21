(* Expressions with high register demand *)

proc foo(a, b, c, d: integer): integer;
begin
  return
    (a-b)*(a-c)*(a-d)*(b-c)*(b-d)*(c-d)
    +
    (a-c)*(a-d)*(b-c)*(b-d)*(c-d)*(a-b)
end;

proc baz(n: integer): integer;
begin
  return (n-1)*(n-1)
end;

begin
  print_num(foo(1,2,3,4)); newline();
  print_num(baz(10)); newline()
end.

(*<<
24
81
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc foo(a, b, c, d: integer): integer;
	.text
_foo:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   return
	ldr r4, [fp, #40]
	ldr r5, [fp, #44]
	sub r6, r4, r5
	ldr r7, [fp, #48]
	sub r8, r4, r7
	ldr r9, [fp, #52]
	sub r4, r4, r9
	sub r0, r5, r7
	sub r5, r5, r9
	sub r7, r7, r9
	mul r1, r6, r8
	mul r1, r1, r4
	mul r1, r1, r0
	mul r1, r1, r5
	mul r1, r1, r7
	mul r2, r8, r4
	mul r0, r2, r0
	mul r0, r0, r5
	mul r0, r0, r7
	mul r0, r0, r6
	add r0, r1, r0
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc baz(n: integer): integer;
_baz:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   return (n-1)*(n-1)
	ldr r0, [fp, #40]
	sub r4, r0, #1
	mul r0, r4, r4
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(foo(1,2,3,4)); newline();
	mov r3, #4
	mov r2, #3
	mov r1, #2
	mov r0, #1
	bl _foo
	bl print_num
	bl newline
@   print_num(baz(10)); newline()
	mov r0, #10
	bl _baz
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
