(* String searching *)

const target = "abracadabra";

var i: integer; found: boolean;

begin
  i := 0; found := false;
  while not found do
    found := target[i] = 'd';
    i := i + 1
  end;
  print_num(i);
  newline()
end.

(*<<
7
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
@   i := 0; found := false;
	mov r0, #0
	set r1, _i
	str r0, [r1]
	mov r0, #0
	set r1, _found
	strb r0, [r1]
.L3:
@   while not found do
	set r4, _found
	ldrb r0, [r4]
	cmp r0, #0
	bne .L5
@     found := target[i] = 'd';
	set r5, _i
	ldr r6, [r5]
	set r0, g1
	add r0, r0, r6
	ldrb r0, [r0]
	cmp r0, #100
	mov r0, #0
	moveq r0, #1
	strb r0, [r4]
@     i := i + 1
	add r0, r6, #1
	str r0, [r5]
	b .L3
.L5:
@   print_num(i);
	set r0, _i
	ldr r0, [r0]
	bl print_num
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _i, 4, 4
	.comm _found, 1, 4
	.data
g1:
	.byte 97, 98, 114, 97, 99, 97, 100, 97, 98, 114
	.byte 97
	.byte 0
@ End
]]*)
