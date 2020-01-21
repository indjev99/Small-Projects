(* Binary search for sqrt(200000000) *)

var y, a, b, m: integer;

begin
  y := 200000000;
  a := 0;
  b := 20000;
  (* Inv: a^2 <= y < b^2 *)
  while a+1 < b do
    m := (a+b) div 2;
    if m*m <= y then
      a := m
    else
      b := m
    end
  end;
  print_num(a); newline()
end. 

(*<<
14142
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
@   y := 200000000;
	set r0, #200000000
	set r1, _y
	str r0, [r1]
@   a := 0;
	mov r0, #0
	set r1, _a
	str r0, [r1]
@   b := 20000;
	set r0, #20000
	set r1, _b
	str r0, [r1]
.L2:
@   while a+1 < b do
	set r0, _a
	ldr r4, [r0]
	set r0, _b
	ldr r5, [r0]
	add r0, r4, #1
	cmp r0, r5
	bge .L4
@     m := (a+b) div 2;
	mov r1, #2
	add r0, r4, r5
	bl int_div
	set r1, _m
	str r0, [r1]
@     if m*m <= y then
	mul r1, r0, r0
	set r2, _y
	ldr r2, [r2]
	cmp r1, r2
	bgt .L6
@       a := m
	set r1, _a
	str r0, [r1]
	b .L2
.L6:
@       b := m
	set r0, _m
	ldr r0, [r0]
	set r1, _b
	str r0, [r1]
	b .L2
.L4:
@   print_num(a); newline()
	set r0, _a
	ldr r0, [r0]
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _y, 4, 4
	.comm _a, 4, 4
	.comm _b, 4, 4
	.comm _m, 4, 4
@ End
]]*)
