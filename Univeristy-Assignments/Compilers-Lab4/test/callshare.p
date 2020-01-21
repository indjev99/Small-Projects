(* Identical function calls are not merged by CSE *)

var x, y: integer;

proc f(n: integer): integer;
begin x := x + n; return x end;

begin
  x := 2;
  y := f(3) + 1;
  y := f(3) + 1;
  print_num(x); newline()
end.

(*<<
8
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc f(n: integer): integer;
	.text
_f:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@ begin x := x + n; return x end;
	set r4, _x
	ldr r0, [r4]
	ldr r1, [fp, #40]
	add r5, r0, r1
	str r5, [r4]
	mov r0, r5
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   x := 2;
	mov r0, #2
	set r1, _x
	str r0, [r1]
@   y := f(3) + 1;
	mov r0, #3
	bl _f
	add r0, r0, #1
	set r1, _y
	str r0, [r1]
@   y := f(3) + 1;
	mov r0, #3
	bl _f
	add r0, r0, #1
	set r1, _y
	str r0, [r1]
@   print_num(x); newline()
	set r0, _x
	ldr r0, [r0]
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _x, 4, 4
	.comm _y, 4, 4
@ End
]]*)
