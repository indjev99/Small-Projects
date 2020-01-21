(* The empty program *)

begin end.

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

	.text
pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
