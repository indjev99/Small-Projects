(* Multiply instructions *)

var x, y, z: integer;

proc f(x: integer): integer;
begin return x end;

proc mmm(x: integer): integer;
begin 
  y := f(x); 
  return y*y 
end;

begin
  x := 3;
  y := 5;
  z := x * y;
  print_num(z);
  newline();
  print_num(mmm(12));
  newline()
end.

(*<<
15
144
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc f(x: integer): integer;
	.text
_f:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@ begin return x end;
	ldr r0, [fp, #40]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc mmm(x: integer): integer;
_mmm:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   y := f(x); 
	ldr r0, [fp, #40]
	bl _f
	set r1, _y
	str r0, [r1]
@   return y*y 
	mul r0, r0, r0
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   x := 3;
	mov r4, #3
	set r0, _x
	str r4, [r0]
@   y := 5;
	mov r5, #5
	set r0, _y
	str r5, [r0]
@   z := x * y;
	mul r4, r4, r5
	set r0, _z
	str r4, [r0]
@   print_num(z);
	mov r0, r4
	bl print_num
@   newline();
	bl newline
@   print_num(mmm(12));
	mov r0, #12
	bl _mmm
	bl print_num
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _x, 4, 4
	.comm _y, 4, 4
	.comm _z, 4, 4
@ End
]]*)
