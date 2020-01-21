proc foo(): integer;
  var i: integer;
begin
  i := 3;
  repeat
    i := i + 2;
    if i > 10 then return i end;
  until false
end;

begin
  print_num(foo()); newline()
end.

(*<<
11
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc foo(): integer;
	.text
_foo:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   i := 3;
	mov r4, #3
.L2:
@     i := i + 2;
	add r4, r4, #2
@     if i > 10 then return i end;
	cmp r4, #10
	ble .L2
	mov r0, r4
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_num(foo()); newline()
	bl _foo
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
