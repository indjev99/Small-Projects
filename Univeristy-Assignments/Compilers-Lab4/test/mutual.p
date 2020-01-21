(* Mutual recursion *)

proc flip(i: integer): integer;
  var r: integer;
begin
  if i = 0 then 
    r := 1
  else 
    r := 2 * flop(i-1)
  end;
  print_string("flip("); print_num(i); 
  print_string(") = "); print_num(r);
  newline();
  return r
end;

proc flop(i: integer): integer;
  var r: integer;
begin
  if i = 0 then 
    r := 1
  else 
    r := flip(i-1) + k
  end;
  print_string("flop("); print_num(i); 
  print_string(") = "); print_num(r);
  newline();
  return r
end;

const k = 5;

begin
  print_num(flip(5));
  newline()
end.

(*<<
flop(0) = 1
flip(1) = 2
flop(2) = 7
flip(3) = 14
flop(4) = 19
flip(5) = 38
38
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc flip(i: integer): integer;
	.text
_flip:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if i = 0 then 
	ldr r0, [fp, #40]
	cmp r0, #0
	bne .L7
@     r := 1
	mov r4, #1
	b .L8
.L7:
@     r := 2 * flop(i-1)
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _flop
	lsl r4, r0, #1
.L8:
@   print_string("flip("); print_num(i); 
	mov r1, #5
	set r0, g1
	bl print_string
	ldr r0, [fp, #40]
	bl print_num
@   print_string(") = "); print_num(r);
	mov r1, #4
	set r0, g2
	bl print_string
	mov r0, r4
	bl print_num
@   newline();
	bl newline
@   return r
	mov r0, r4
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc flop(i: integer): integer;
_flop:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if i = 0 then 
	ldr r0, [fp, #40]
	cmp r0, #0
	bne .L11
@     r := 1
	mov r4, #1
	b .L12
.L11:
@     r := flip(i-1) + k
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _flip
	add r4, r0, #5
.L12:
@   print_string("flop("); print_num(i); 
	mov r1, #5
	set r0, g3
	bl print_string
	ldr r0, [fp, #40]
	bl print_num
@   print_string(") = "); print_num(r);
	mov r1, #4
	set r0, g4
	bl print_string
	mov r0, r4
	bl print_num
@   newline();
	bl newline
@   return r
	mov r0, r4
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

	.data
g1:
	.byte 102, 108, 105, 112, 40
	.byte 0
g2:
	.byte 41, 32, 61, 32
	.byte 0
g3:
	.byte 102, 108, 111, 112, 40
	.byte 0
g4:
	.byte 41, 32, 61, 32
	.byte 0
@ End
]]*)
