(* Enumerate (n choose k) choices by recursion *)

const letters = "abcdef";

var buf: array 10 of char;

(* Complete choice with k items chosen from [0..n) *)
proc choose(k, n: integer);
begin
  if k <= n then
    if k = 0 then
      print_string(buf); newline()
    else
      choose(k, n-1);
      buf[k-1] := letters[n-1];
      choose(k-1, n-1);
    end
  end
end;

begin
  choose(3, 6)
end.    

(*<<
abc
abd
acd
bcd
abe
ace
bce
ade
bde
cde
abf
acf
bcf
adf
bdf
cdf
aef
bef
cef
def
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc choose(k, n: integer);
	.text
_choose:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if k <= n then
	ldr r4, [fp, #40]
	ldr r0, [fp, #44]
	cmp r4, r0
	bgt .L5
@     if k = 0 then
	cmp r4, #0
	bne .L7
@       print_string(buf); newline()
	mov r1, #10
	set r0, _buf
	bl print_string
	bl newline
	b .L5
.L7:
@       choose(k, n-1);
	ldr r0, [fp, #44]
	sub r1, r0, #1
	ldr r0, [fp, #40]
	bl _choose
@       buf[k-1] := letters[n-1];
	ldr r4, [fp, #44]
	ldr r5, [fp, #40]
	set r0, g1
	add r0, r0, r4
	ldrb r0, [r0, #-1]
	set r1, _buf
	add r1, r1, r5
	strb r0, [r1, #-1]
@       choose(k-1, n-1);
	sub r1, r4, #1
	sub r0, r5, #1
	bl _choose
.L5:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   choose(3, 6)
	mov r1, #6
	mov r0, #3
	bl _choose
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _buf, 10, 4
	.data
g1:
	.byte 97, 98, 99, 100, 101, 102
	.byte 0
@ End
]]*)
