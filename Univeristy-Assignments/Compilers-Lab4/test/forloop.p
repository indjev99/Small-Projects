var i: integer;

begin
  for i := 1 to 5 do
    print_num(i);
    newline()
  end
end.

(*<<
1
2
3
4
5
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
@   for i := 1 to 5 do
	mov r0, #1
	set r1, _i
	str r0, [r1]
	mov r4, #5
.L2:
	set r0, _i
	ldr r5, [r0]
	cmp r5, r4
	bgt .L1
@     print_num(i);
	mov r0, r5
	bl print_num
@     newline()
	bl newline
	set r5, _i
	ldr r0, [r5]
	add r0, r0, #1
	str r0, [r5]
	b .L2
.L1:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _i, 4, 4
@ End
]]*)
