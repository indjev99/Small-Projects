(* Higher-order functions *)

proc sum(a, b: integer; proc f(x: integer): integer): integer;
  var i, s: integer;
begin
  i := a; s := 0;
  while i <= b do
    s := s + f(i);
    i := i + 1
  end;
  return s
end;

proc sum_powers(a, b, n: integer): integer;
  proc pow(x: integer): integer;
    var j, p: integer;
  begin
    j := 0; p := 1;
    while j < n do
      p := p * x;
      j := j + 1
    end;
    return p
  end;
begin
  return sum(a, b, pow)
end;

begin
  print_num(sum_powers(1, 10, 3));
  newline()
end.

(*<<
3025
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc sum(a, b: integer; proc f(x: integer): integer): integer;
	.text
_sum:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   i := a; s := 0;
	ldr r4, [fp, #40]
	mov r5, #0
.L2:
@   while i <= b do
	ldr r0, [fp, #44]
	cmp r4, r0
	bgt .L4
@     s := s + f(i);
	mov r0, r4
	ldr r10, [fp, #52]
	ldr r1, [fp, #48]
	blx r1
	add r5, r5, r0
@     i := i + 1
	add r4, r4, #1
	b .L2
.L4:
@   return s
	mov r0, r5
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc sum_powers(a, b, n: integer): integer;
_sum_powers:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   return sum(a, b, pow)
	mov r3, fp
	set r2, _pow
	ldr r1, [fp, #44]
	ldr r0, [fp, #40]
	bl _sum
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@   proc pow(x: integer): integer;
_pow:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@     j := 0; p := 1;
	mov r4, #0
	mov r5, #1
.L7:
@     while j < n do
	ldr r0, [fp, #24]
	ldr r0, [r0, #48]
	cmp r4, r0
	bge .L9
@       p := p * x;
	ldr r0, [fp, #40]
	mul r5, r5, r0
@       j := j + 1
	add r4, r4, #1
	b .L7
.L9:
@     return p
	mov r0, r5
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(sum_powers(1, 10, 3));
	mov r2, #3
	mov r1, #10
	mov r0, #1
	bl _sum_powers
	bl print_num
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
