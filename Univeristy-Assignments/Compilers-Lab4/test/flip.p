(* Nested functions with mutual recursion *)

proc flip(x: integer): integer;
  proc flop(y: integer): integer;
  begin
    if y = 0 then return 1 else return flip(y-1) + x end
  end;
begin
  if x = 0 then return 1 else return 2 * flop(x-1) end
end;

begin
  print_num(flip(5));
  newline()
end.

(* flip(5) = 2 * flop(4) = 2 * (flip(3) + 5)
    = 4 * flop(2) + 10 = 4 * (flip(1) + 3) + 10
    = 8 * flop(0) + 22 = 30 *)

(*<<
30
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc flip(x: integer): integer;
	.text
_flip:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if x = 0 then return 1 else return 2 * flop(x-1) end
	ldr r0, [fp, #40]
	cmp r0, #0
	bne .L3
	mov r0, #1
	b .L1
.L3:
	ldr r0, [fp, #40]
	sub r0, r0, #1
	mov r10, fp
	bl _flop
	lsl r0, r0, #1
.L1:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@   proc flop(y: integer): integer;
_flop:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@     if y = 0 then return 1 else return flip(y-1) + x end
	ldr r0, [fp, #40]
	cmp r0, #0
	bne .L7
	mov r0, #1
	b .L5
.L7:
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _flip
	ldr r1, [fp, #24]
	ldr r1, [r1, #40]
	add r0, r0, r1
.L5:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(flip(5));
	mov r0, #5
	bl _flip
	bl print_num
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
