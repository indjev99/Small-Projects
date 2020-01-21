(* Procedure to swap elements of array *)

const n = 10;

var a: array n of integer; 

proc swap(i, j: integer);
  var t: integer;
begin
  t := a[i]; 
  a[i] := a[j]; 
  a[j] := t
end;

proc main();
  var i: integer;
begin
  for i := 0 to n-1 do a[i] := i end;
  swap(3, 6);
  for i := 0 to n-1 do print_num(a[i]) end;
  newline()
end;

begin 
  main()
end.

(*<<
0126453789
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc swap(i, j: integer);
	.text
_swap:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   t := a[i]; 
	set r5, _a
	ldr r0, [fp, #40]
	lsl r0, r0, #2
	add r6, r5, r0
	ldr r4, [r6]
@   a[i] := a[j]; 
	ldr r0, [fp, #44]
	lsl r0, r0, #2
	add r5, r5, r0
	ldr r0, [r5]
	str r0, [r6]
@   a[j] := t
	str r4, [r5]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc main();
_main:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   for i := 0 to n-1 do a[i] := i end;
	mov r4, #0
	mov r5, #9
.L3:
	cmp r4, r5
	bgt .L4
	set r0, _a
	lsl r1, r4, #2
	add r0, r0, r1
	str r4, [r0]
	add r4, r4, #1
	b .L3
.L4:
@   swap(3, 6);
	mov r1, #6
	mov r0, #3
	bl _swap
@   for i := 0 to n-1 do print_num(a[i]) end;
	mov r4, #0
	mov r6, #9
.L5:
	cmp r4, r6
	bgt .L6
	set r0, _a
	lsl r1, r4, #2
	add r0, r0, r1
	ldr r0, [r0]
	bl print_num
	add r4, r4, #1
	b .L5
.L6:
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   main()
	bl _main
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _a, 40, 4
@ End
]]*)
