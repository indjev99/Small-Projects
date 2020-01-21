(* Bitwise NOT function *)

var x: integer;
begin
  x := 314159265;
  x := bitnot(x);
  print_num(x); newline()
end.

(*<<
-314159266
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
@   x := 314159265;
	set r4, #314159265
	set r5, _x
	str r4, [r5]
@   x := bitnot(x);
	mvn r4, r4
	str r4, [r5]
@   print_num(x); newline()
	mov r0, r4
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _x, 4, 4
@ End
]]*)
