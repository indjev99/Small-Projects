(* Local and global arrays *)

var i: integer;

var a: array 10 of integer;

proc foo();
  var j: integer;
  var b : array 10 of integer;
begin
  print_string("foo"); newline();
  j := 2; b[0] := 1; b[1] := 1;
  while 10 > j do
    b[j] := b[j-2] + b[j-1];
    print_char(' '); print_num(b[j]);
    j := 1+j
  end;
  newline();
end;

begin
  print_string("baz"); newline();
  i := 2; a[0] := 1; a[1] := 1;
  while i < 10 do
    a[i] := a[i-2] + a[i-1];
    print_char(' '); print_num(a[i]);
    i := i+1
  end;
  newline();
  foo()
end.

(*<<
baz
 2 3 5 8 13 21 34 55
foo
 2 3 5 8 13 21 34 55
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc foo();
	.text
_foo:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	sub sp, sp, #40
@   print_string("foo"); newline();
	mov r1, #3
	set r0, g1
	bl print_string
	bl newline
@   j := 2; b[0] := 1; b[1] := 1;
	mov r4, #2
	mov r0, #1
	str r0, [fp, #-40]
	mov r0, #1
	str r0, [fp, #-36]
.L4:
@   while 10 > j do
	cmp r4, #10
	bge .L6
@     b[j] := b[j-2] + b[j-1];
	add r0, fp, #-40
	lsl r1, r4, #2
	add r5, r0, r1
	ldr r0, [r5, #-8]
	ldr r1, [r5, #-4]
	add r0, r0, r1
	str r0, [r5]
@     print_char(' '); print_num(b[j]);
	mov r0, #32
	bl print_char
	add r0, fp, #-40
	lsl r1, r4, #2
	add r0, r0, r1
	ldr r0, [r0]
	bl print_num
@     j := 1+j
	add r4, r4, #1
	b .L4
.L6:
@   newline();
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_string("baz"); newline();
	mov r1, #3
	set r0, g2
	bl print_string
	bl newline
@   i := 2; a[0] := 1; a[1] := 1;
	mov r0, #2
	set r1, _i
	str r0, [r1]
	set r4, _a
	mov r0, #1
	str r0, [r4]
	mov r0, #1
	str r0, [r4, #4]
.L8:
@   while i < 10 do
	set r0, _i
	ldr r4, [r0]
	cmp r4, #10
	bge .L10
@     a[i] := a[i-2] + a[i-1];
	set r0, _a
	lsl r1, r4, #2
	add r4, r0, r1
	ldr r0, [r4, #-8]
	ldr r1, [r4, #-4]
	add r0, r0, r1
	str r0, [r4]
@     print_char(' '); print_num(a[i]);
	mov r0, #32
	bl print_char
	set r0, _a
	set r1, _i
	ldr r1, [r1]
	lsl r1, r1, #2
	add r0, r0, r1
	ldr r0, [r0]
	bl print_num
@     i := i+1
	set r4, _i
	ldr r0, [r4]
	add r0, r0, #1
	str r0, [r4]
	b .L8
.L10:
@   newline();
	bl newline
@   foo()
	bl _foo
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _i, 4, 4
	.comm _a, 40, 4
	.data
g1:
	.byte 102, 111, 111
	.byte 0
g2:
	.byte 98, 97, 122
	.byte 0
@ End
]]*)
