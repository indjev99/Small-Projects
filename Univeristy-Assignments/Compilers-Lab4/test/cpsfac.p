(* Compute factorials using CPS *)

proc fac(n: integer; proc k(r: integer): integer): integer;
  proc k1(r: integer): integer;
    var r1: integer;
  begin
    r1 := n * r;
    print_num(n); print_string(" * "); print_num(r);
    print_string(" = "); print_num(r1); newline();
    return k(r1) 
  end;
begin 
  if n = 0 then return k(1) else return fac(n-1, k1) end
end;

proc id(r: integer): integer;
begin 
  return r 
end;

begin 
  print_num(fac(10, id));
  newline()
end.

(*<<
1 * 1 = 1
2 * 1 = 2
3 * 2 = 6
4 * 6 = 24
5 * 24 = 120
6 * 120 = 720
7 * 720 = 5040
8 * 5040 = 40320
9 * 40320 = 362880
10 * 362880 = 3628800
3628800
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc fac(n: integer; proc k(r: integer): integer): integer;
	.text
_fac:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if n = 0 then return k(1) else return fac(n-1, k1) end
	ldr r0, [fp, #40]
	cmp r0, #0
	bne .L5
	mov r0, #1
	ldr r10, [fp, #48]
	ldr r1, [fp, #44]
	blx r1
	b .L3
.L5:
	mov r2, fp
	set r1, _k1
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _fac
.L3:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@   proc k1(r: integer): integer;
_k1:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@     r1 := n * r;
	ldr r0, [fp, #24]
	ldr r5, [r0, #40]
	ldr r0, [fp, #40]
	mul r4, r5, r0
@     print_num(n); print_string(" * "); print_num(r);
	mov r0, r5
	bl print_num
	mov r1, #3
	set r0, g1
	bl print_string
	ldr r0, [fp, #40]
	bl print_num
@     print_string(" = "); print_num(r1); newline();
	mov r1, #3
	set r0, g2
	bl print_string
	mov r0, r4
	bl print_num
	bl newline
@     return k(r1) 
	ldr r5, [fp, #24]
	mov r0, r4
	ldr r10, [r5, #48]
	ldr r1, [r5, #44]
	blx r1
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc id(r: integer): integer;
_id:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   return r 
	ldr r0, [fp, #40]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(fac(10, id));
	mov r2, #0
	set r1, _id
	mov r0, #10
	bl _fac
	bl print_num
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.data
g1:
	.byte 32, 42, 32
	.byte 0
g2:
	.byte 32, 61, 32
	.byte 0
@ End
]]*)
