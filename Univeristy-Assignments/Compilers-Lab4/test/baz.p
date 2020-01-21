(* Assigning to a global variable from a procedure *)

var x: integer;

proc baz(u: integer): integer;
begin
  x := u;
  return x
end;
  
begin
  print_num(baz(37)); newline();
  print_num(x); newline()
end.

(*<<
37
37
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc baz(u: integer): integer;
	.text
_baz:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   x := u;
	ldr r4, [fp, #40]
	set r0, _x
	str r4, [r0]
@   return x
	mov r0, r4
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(baz(37)); newline();
	mov r0, #37
	bl _baz
	bl print_num
	bl newline
@   print_num(x); newline()
	set r0, _x
	ldr r0, [r0]
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _x, 4, 4
@ End
]]*)
