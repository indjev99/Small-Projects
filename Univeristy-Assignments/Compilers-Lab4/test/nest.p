(* Nested calls *)

proc f(x: integer): integer; begin return 2*x end;
begin print_num(f(f(3))); newline() end.

(*<<
12
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc f(x: integer): integer; begin return 2*x end;
	.text
_f:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@ proc f(x: integer): integer; begin return 2*x end;
	ldr r0, [fp, #40]
	lsl r0, r0, #1
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@ begin print_num(f(f(3))); newline() end.
	mov r0, #3
	bl _f
	bl _f
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
