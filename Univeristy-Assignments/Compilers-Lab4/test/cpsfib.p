(* Fibonacci numbers in CPS *)

(* This program computes fibonacci numbers using the usual doubly
   recursive algorithm.  However, the algorithm has been transformed
   into continuation passing style.  A good test for procedural
   parameters! *)

(* fib -- fibonacci numbers *)
proc fib(n: integer): integer;

  (* fib1 -- continuation transformer for fib *)
  proc fib1(n: integer; proc k(r: integer): integer) : integer;
    proc k1(r1: integer): integer;
      proc k2(r2: integer): integer; begin return k(r1 + r2) end;
    begin return fib1(n-2, k2) end;
  begin
    if n <= 1 then 
      return k(1) 
    else 
      return fib1(n-1, k1)
    end
  end;

  (* id -- identity continuation *)
  proc id(r: integer): integer; begin return r end;

begin
  return fib1(n, id)
end;

begin
  print_num(fib(6)); newline()
end.

(*<<
13
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc fib(n: integer): integer;
	.text
_fib:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   return fib1(n, id)
	mov r2, fp
	set r1, _id
	ldr r0, [fp, #40]
	mov r10, fp
	bl _fib1
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@   proc fib1(n: integer; proc k(r: integer): integer) : integer;
_fib1:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@     if n <= 1 then 
	ldr r0, [fp, #40]
	cmp r0, #1
	bgt .L4
@       return k(1) 
	mov r0, #1
	ldr r10, [fp, #48]
	ldr r1, [fp, #44]
	blx r1
	b .L2
.L4:
@       return fib1(n-1, k1)
	mov r2, fp
	set r1, _k1
	ldr r0, [fp, #40]
	sub r0, r0, #1
	ldr r10, [fp, #24]
	bl _fib1
.L2:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@     proc k1(r1: integer): integer;
_k1:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@     begin return fib1(n-2, k2) end;
	ldr r4, [fp, #24]
	mov r2, fp
	set r1, _k2
	ldr r0, [r4, #40]
	sub r0, r0, #2
	ldr r10, [r4, #24]
	bl _fib1
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@       proc k2(r2: integer): integer; begin return k(r1 + r2) end;
_k2:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@       proc k2(r2: integer): integer; begin return k(r1 + r2) end;
	ldr r4, [fp, #24]
	ldr r5, [r4, #24]
	ldr r0, [r4, #40]
	ldr r1, [fp, #40]
	add r0, r0, r1
	ldr r10, [r5, #48]
	ldr r1, [r5, #44]
	blx r1
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@   proc id(r: integer): integer; begin return r end;
_id:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   proc id(r: integer): integer; begin return r end;
	ldr r0, [fp, #40]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(fib(6)); newline()
	mov r0, #6
	bl _fib
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
