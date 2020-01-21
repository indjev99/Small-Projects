(* Compute (n choose k) by recursion *)

proc choose(n, k: integer): integer;
begin
  if n = 0 then
    if k = 0 then
      return 1
    else
      return 0
    end
  else
    return choose(n-1, k-1) + choose(n-1, k)
  end
end;

begin
  print_num(choose(6,4));
  newline()
end.

(*<<
15
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc choose(n, k: integer): integer;
	.text
_choose:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if n = 0 then
	ldr r0, [fp, #40]
	cmp r0, #0
	bne .L3
@     if k = 0 then
	ldr r0, [fp, #44]
	cmp r0, #0
	bne .L6
@       return 1
	mov r0, #1
	b .L1
.L6:
@       return 0
	mov r0, #0
	b .L1
.L3:
@     return choose(n-1, k-1) + choose(n-1, k)
	ldr r0, [fp, #44]
	sub r1, r0, #1
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _choose
	ldr r1, [fp, #44]
	mov r4, r0
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _choose
	add r0, r4, r0
.L1:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(choose(6,4));
	mov r1, #4
	mov r0, #6
	bl _choose
	bl print_num
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
