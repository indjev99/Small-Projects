(* Fibonacci numbers by the usual recursion *)

(* fib -- fibonacci numbers *)
proc fib(n: integer): integer;
begin
  if n <= 1 then 
    return 1 
  else 
    return fib(n-1) + fib(n-2)
  end
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
@   if n <= 1 then 
	ldr r0, [fp, #40]
	cmp r0, #1
	bgt .L3
@     return 1 
	mov r0, #1
	b .L1
.L3:
@     return fib(n-1) + fib(n-2)
	ldr r0, [fp, #40]
	sub r0, r0, #1
	bl _fib
	mov r4, r0
	ldr r0, [fp, #40]
	sub r0, r0, #2
	bl _fib
	add r0, r4, r0
.L1:
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
