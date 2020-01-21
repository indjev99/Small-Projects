(* From a problem sheet *)

proc double(x: integer): integer;
begin
  return x + x
end;

proc apply3(proc f(x:integer): integer): integer;
begin
  return f(3)
end;

begin
  print_num(apply3(double));
  newline()
end.

(*<<
6
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc double(x: integer): integer;
	.text
_double:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   return x + x
	ldr r4, [fp, #40]
	add r0, r4, r4
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc apply3(proc f(x:integer): integer): integer;
_apply3:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   return f(3)
	mov r0, #3
	ldr r10, [fp, #44]
	ldr r1, [fp, #40]
	blx r1
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(apply3(double));
	mov r1, #0
	set r0, _double
	bl _apply3
	bl print_num
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
