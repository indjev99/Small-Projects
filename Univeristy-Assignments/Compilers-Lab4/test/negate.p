(* Negation of booleans and integers *)

var x, y: boolean;
var u, v: integer;

begin
  x := true;
  y := not x;
  y := not y;
  if x = y then
    print_string("OK"); newline()
  end;

  u := 37;
  v := -u;
  v := -v;
  if u = v then
    print_string("OK2"); newline()
  end
end.

(*<<
OK
OK2
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
@   x := true;
	mov r4, #1
	set r0, _x
	strb r4, [r0]
@   y := not x;
	eor r5, r4, #1
	set r6, _y
	strb r5, [r6]
@   y := not y;
	eor r5, r5, #1
	strb r5, [r6]
@   if x = y then
	cmp r4, r5
	bne .L6
@     print_string("OK"); newline()
	mov r1, #2
	set r0, g1
	bl print_string
	bl newline
.L6:
@   u := 37;
	mov r4, #37
	set r0, _u
	str r4, [r0]
@   v := -u;
	neg r5, r4
	set r6, _v
	str r5, [r6]
@   v := -v;
	neg r5, r5
	str r5, [r6]
@   if u = v then
	cmp r4, r5
	bne .L3
@     print_string("OK2"); newline()
	mov r1, #3
	set r0, g2
	bl print_string
	bl newline
.L3:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _x, 1, 4
	.comm _y, 1, 4
	.comm _u, 4, 4
	.comm _v, 4, 4
	.data
g1:
	.byte 79, 75
	.byte 0
g2:
	.byte 79, 75, 50
	.byte 0
@ End
]]*)
