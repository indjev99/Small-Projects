(* Simple recursion *)

proc repchar(c: char; n: integer);
  var i: integer;
begin
  if n > 0 then
    print_char(c);
    repchar(c, n-1)
  end
end;

begin
  repchar('A', 3);
  repchar('B', 5);
  newline()
end.

(*<<
AAABBBBB
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc repchar(c: char; n: integer);
	.text
_repchar:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if n > 0 then
	ldr r0, [fp, #44]
	cmp r0, #0
	ble .L1
@     print_char(c);
	ldrb r0, [fp, #40]
	bl print_char
@     repchar(c, n-1)
	ldr r0, [fp, #44]
	sub r1, r0, #1
	ldrb r0, [fp, #40]
	bl _repchar
.L1:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   repchar('A', 3);
	mov r1, #3
	mov r0, #65
	bl _repchar
@   repchar('B', 5);
	mov r1, #5
	mov r0, #66
	bl _repchar
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
