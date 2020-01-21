(* Spill result of function call *)

proc f(x: integer): integer;
begin
  return x
end;

begin
  print_num(f(3)+f(4)); newline()
end.

(*<<
7
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
@   return x
	ldr r0, [fp, #40]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(f(3)+f(4)); newline()
	mov r0, #3
	bl _f
	mov r4, r0
	mov r0, #4
	bl _f
	mov r5, r0
	add r0, r4, r5
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
