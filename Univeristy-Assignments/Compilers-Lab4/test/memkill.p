(* All loads are killed by a procedure call *)

proc f(): integer;
  var x, y: integer;
begin
  x := 3;
  y := x + 1;
  g();
  return x + 1
end;

proc g(); begin end;

begin
  print_num(f()); newline()
end.

(*<<
4
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc f(): integer;
	.text
_f:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   x := 3;
	mov r4, #3
@   y := x + 1;
	add r5, r4, #1
@   g();
	bl _g
@   return x + 1
	add r0, r4, #1
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc g(); begin end;
_g:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(f()); newline()
	bl _f
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
