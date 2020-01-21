(* Representation of immediate constants *)

var k: integer;
begin
  k := 100;
  print_num(516); newline();
  print_num(517); newline();
  print_num(k + -50); newline();
  print_num(k + -1023); newline();
  print_num(k + -1024); newline()
end.

(*<<
516
517
50
-923
-924
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

	.text
pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   k := 100;
	mov r0, #100
	set r1, _k
	str r0, [r1]
@   print_num(516); newline();
	mov r0, #516
	bl print_num
	bl newline
@   print_num(517); newline();
	set r0, #517
	bl print_num
	bl newline
@   print_num(k + -50); newline();
	set r0, _k
	ldr r0, [r0]
	sub r0, r0, #50
	bl print_num
	bl newline
@   print_num(k + -1023); newline();
	set r0, _k
	ldr r0, [r0]
	set r1, #1023
	sub r0, r0, r1
	bl print_num
	bl newline
@   print_num(k + -1024); newline()
	set r0, _k
	ldr r0, [r0]
	sub r0, r0, #1024
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _k, 4, 4
@ End
]]*)
