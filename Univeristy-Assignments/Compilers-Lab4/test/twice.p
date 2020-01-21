(* Another test of higher-order functions *)

type int = integer;

proc square(x: int): int; begin return x * x end;

proc twice(proc f(y: int): int; x: int): int;
begin return f(f(x)) end;

proc ap_to_sq(proc ff(proc f(x: int): int; x: int): int; x: int): int;
begin return ff(square, x) end;

begin
  print_num(ap_to_sq(twice, 3));
  newline()
end.

(*<<
81
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc square(x: int): int; begin return x * x end;
	.text
_square:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@ proc square(x: int): int; begin return x * x end;
	ldr r4, [fp, #40]
	mul r0, r4, r4
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc twice(proc f(y: int): int; x: int): int;
_twice:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@ begin return f(f(x)) end;
	ldr r4, [fp, #40]
	ldr r5, [fp, #44]
	ldr r0, [fp, #48]
	mov r10, r5
	blx r4
	mov r10, r5
	blx r4
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc ap_to_sq(proc ff(proc f(x: int): int; x: int): int; x: int): int;
_ap_to_sq:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@ begin return ff(square, x) end;
	ldr r2, [fp, #48]
	mov r1, #0
	set r0, _square
	ldr r10, [fp, #44]
	ldr r3, [fp, #40]
	blx r3
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(ap_to_sq(twice, 3));
	mov r2, #3
	mov r1, #0
	set r0, _twice
	bl _ap_to_sq
	bl print_num
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
