(* Enumerate (n choose k) choices with nested functions *)

const letters = "abcdef";

(* Complete suffix with k items chosen from [0..n) *)
proc choose(k, n: integer; proc suffix());
  proc suffix1();
  begin
    print_char(letters[n-1]); suffix()
  end;
begin
  if k <= n then
    if k = 0 then
      suffix(); newline()
    else
      choose(k, n-1, suffix);
      choose(k-1, n-1, suffix1)
    end
  end
end;

proc null(); begin end;

begin
  choose(3, 6, null)
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

@ proc choose(k, n: integer; proc suffix());
	.text
_choose:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if k <= n then
	ldr r4, [fp, #40]
	ldr r0, [fp, #44]
	cmp r4, r0
	bgt .L2
@     if k = 0 then
	cmp r4, #0
	bne .L7
@       suffix(); newline()
	ldr r10, [fp, #52]
	ldr r0, [fp, #48]
	blx r0
	bl newline
	b .L2
.L7:
@       choose(k, n-1, suffix);
	ldr r3, [fp, #52]
	ldr r2, [fp, #48]
	ldr r0, [fp, #44]
	sub r1, r0, #1
	ldr r0, [fp, #40]
	bl _choose
@       choose(k-1, n-1, suffix1)
	mov r3, fp
	set r2, _suffix1
	ldr r0, [fp, #44]
	sub r1, r0, #1
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _choose
.L2:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@   proc suffix1();
_suffix1:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@     print_char(letters[n-1]); suffix()
	set r0, g1
	ldr r1, [fp, #24]
	ldr r1, [r1, #44]
	add r0, r0, r1
	ldrb r0, [r0, #-1]
	bl print_char
	ldr r4, [fp, #24]
	ldr r10, [r4, #52]
	ldr r0, [r4, #48]
	blx r0
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc null(); begin end;
_null:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   choose(3, 6, null)
	mov r3, #0
	set r2, _null
	mov r1, #6
	mov r0, #3
	bl _choose
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.data
g1:
	.byte 97, 98, 99, 100, 101, 102
	.byte 0
@ End
]]*)
