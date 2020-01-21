(* Printing strings *)

begin
  print_string("five"); newline()
end.

(*<<
five
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
@   print_string("five"); newline()
	mov r1, #4
	set r0, g1
	bl print_string
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.data
g1:
	.byte 102, 105, 118, 101
	.byte 0
@ End
]]*)
