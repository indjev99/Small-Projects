(* Order of evaluation and unnesting of procedure calls *)

var x, y, z: integer;

proc nasty(x: integer): integer;
begin
  y := 1;
  return 2 * x;
end;

begin
  x := 3; y := 5;
  z := y + nasty(x);
  print_num(z); newline()
end.

(* Gives 7 without optimisation owing to lifting of procedure call;
   with full CSE, gives 11 because the two occurrences of y can share. *)

(*<<
11
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc nasty(x: integer): integer;
	.text
_nasty:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   y := 1;
	mov r0, #1
	set r1, _y
	str r0, [r1]
@   return 2 * x;
	ldr r0, [fp, #40]
	lsl r0, r0, #1
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   x := 3; y := 5;
	mov r4, #3
	set r0, _x
	str r4, [r0]
	mov r5, #5
	set r0, _y
	str r5, [r0]
@   z := y + nasty(x);
	mov r0, r4
	bl _nasty
	add r4, r5, r0
	set r0, _z
	str r4, [r0]
@   print_num(z); newline()
	mov r0, r4
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _x, 4, 4
	.comm _y, 4, 4
	.comm _z, 4, 4
@ End
]]*)

