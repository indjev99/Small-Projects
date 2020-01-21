(* Large local array and large array parameter *)

proc foo(var a: array 10000 of integer);
  var c: array 10000 of integer; x: integer;
begin 
  x := 5000;
  c[5000] := 4;
  a[5000] := c[x]+3 
end;

var b: array 10000 of integer;
begin foo(b) end.

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc foo(var a: array 10000 of integer);
	.text
_foo:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	set ip, #40000
	sub sp, sp, ip
@   x := 5000;
	set r4, #5000
@   c[5000] := 4;
	mov r0, #4
	set ip, #-20000
	add r1, fp, ip
	str r0, [r1]
@   a[5000] := c[x]+3 
	set ip, #-40000
	add r0, fp, ip
	lsl r1, r4, #2
	add r0, r0, r1
	ldr r0, [r0]
	add r0, r0, #3
	ldr r1, [fp, #40]
	set r2, #20000
	add r1, r1, r2
	str r0, [r1]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@ begin foo(b) end.
	set r0, _b
	bl _foo
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _b, 40000, 4
@ End
]]*)
