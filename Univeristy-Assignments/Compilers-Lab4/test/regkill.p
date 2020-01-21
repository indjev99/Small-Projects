(* Aliasing in CSE *)

var x: integer;

proc p();
var y, z: integer;
begin
  y := 1;
  z := y + 1;
  z := 3;
  z := y + 1;
  x := z
end;

begin
  p();
  print_num(x);
  newline()
end.

(*<<
2
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc p();
	.text
_p:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   y := 1;
	mov r4, #1
@   z := y + 1;
	add r5, r4, #1
@   z := 3;
	mov r5, #3
@   z := y + 1;
	add r5, r4, #1
@   x := z
	set r0, _x
	str r5, [r0]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   p();
	bl _p
@   print_num(x);
	set r0, _x
	ldr r0, [r0]
	bl print_num
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _x, 4, 4
@ End
]]*)
