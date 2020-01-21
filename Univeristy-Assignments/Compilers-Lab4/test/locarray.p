(* Local array *)

proc P();
  var i: integer; x: integer; a: array 10 of integer;
begin
  i := 0;
  x := a[i]
end;

begin
  P()
end.

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc P();
	.text
_P:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	sub sp, sp, #40
@   i := 0;
	mov r4, #0
@   x := a[i]
	add r0, fp, #-40
	lsl r1, r4, #2
	add r0, r0, r1
	ldr r5, [r0]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   P()
	bl _P
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
