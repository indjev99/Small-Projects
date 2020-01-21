(* Pascal's triangle with a 2-dim array *)

const n = 10;

proc pascal2();
  var i, j: integer;
  var a: array n of array n+1 of integer;
begin
  i := 0;
  while i < n do
    a[i][0] := 1; j := 1;
    print_num(a[i][0]);
    while j <= i do
      a[i][j] := a[i-1][j-1] + a[i-1][j];
      print_char(' '); print_num(a[i][j]);
      j := j+1
    end;
    a[i][i+1] := 0;
    newline();
    i := i+1
  end
end;

begin
  pascal2()
end.

(*<<
1
1 1
1 2 1
1 3 3 1
1 4 6 4 1
1 5 10 10 5 1
1 6 15 20 15 6 1
1 7 21 35 35 21 7 1
1 8 28 56 70 56 28 8 1
1 9 36 84 126 126 84 36 9 1
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc pascal2();
	.text
_pascal2:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	sub sp, sp, #440
@   i := 0;
	mov r4, #0
.L2:
@   while i < n do
	cmp r4, #10
	bge .L1
@     a[i][0] := 1; j := 1;
	mov r6, #1
	add r0, fp, #-440
	mov r1, #44
	mul r1, r4, r1
	add r0, r0, r1
	str r6, [r0]
	mov r5, #1
@     print_num(a[i][0]);
	mov r0, r6
	bl print_num
.L5:
@     while j <= i do
	cmp r5, r4
	bgt .L7
@       a[i][j] := a[i-1][j-1] + a[i-1][j];
	add r0, fp, #-440
	mov r1, #44
	mul r1, r4, r1
	add r6, r0, r1
	lsl r7, r5, #2
	add r0, r6, #-44
	add r8, r0, r7
	ldr r0, [r8, #-4]
	ldr r1, [r8]
	add r0, r0, r1
	add r1, r6, r7
	str r0, [r1]
@       print_char(' '); print_num(a[i][j]);
	mov r0, #32
	bl print_char
	add r0, fp, #-440
	mov r1, #44
	mul r1, r4, r1
	add r0, r0, r1
	lsl r1, r5, #2
	add r0, r0, r1
	ldr r0, [r0]
	bl print_num
@       j := j+1
	add r5, r5, #1
	b .L5
.L7:
@     a[i][i+1] := 0;
	mov r0, #0
	add r1, fp, #-440
	mov r2, #44
	mul r2, r4, r2
	add r1, r1, r2
	lsl r2, r4, #2
	add r1, r1, r2
	str r0, [r1, #4]
@     newline();
	bl newline
@     i := i+1
	add r4, r4, #1
	b .L2
.L1:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   pascal2()
	bl _pascal2
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
