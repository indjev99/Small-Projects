var i, j, k: integer;
begin
  i := 0;
  repeat
    j := 1;
    repeat
      j := j+1; k := k+1; 
    until j > i;
    i := i+1
  until i > 10;
  print_num(k); newline()
end.

(*<<
56
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
@   i := 0;
	mov r0, #0
	set r1, _i
	str r0, [r1]
.L2:
@     j := 1;
	mov r0, #1
	set r1, _j
	str r0, [r1]
.L4:
@       j := j+1; k := k+1; 
	set r4, _j
	ldr r0, [r4]
	add r5, r0, #1
	str r5, [r4]
	set r4, _k
	ldr r0, [r4]
	add r6, r0, #1
	str r6, [r4]
@     until j > i;
	set r4, _i
	ldr r7, [r4]
	cmp r5, r7
	ble .L4
@     i := i+1
	add r5, r7, #1
	str r5, [r4]
	cmp r5, #10
	ble .L2
@   print_num(k); newline()
	mov r0, r6
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _i, 4, 4
	.comm _j, 4, 4
	.comm _k, 4, 4
@ End
]]*)
