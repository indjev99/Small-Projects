(* String copying by loop *)

const in = "Hello, world!*";

var out: array 128 of char; i: integer;

begin
  i := 0;
  while in[i] <> '*' do
    out[i] := in[i];
    i := i + 1
  end;
  out[i] := chr(0);
  print_string(out); newline()
end.

(*<<
Hello, world!
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

	.text
pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   i := 0;
	mov r0, #0
	set r1, _i
	str r0, [r1]
.L3:
@   while in[i] <> '*' do
	set r4, _i
	ldr r5, [r4]
	set r0, g1
	add r0, r0, r5
	ldrb r6, [r0]
	cmp r6, #42
	beq .L5
@     out[i] := in[i];
	set r0, _out
	add r0, r0, r5
	strb r6, [r0]
@     i := i + 1
	ldr r0, [r4]
	add r0, r0, #1
	str r0, [r4]
	b .L3
.L5:
@   out[i] := chr(0);
	set r4, _out
	mov r0, #0
	set r1, _i
	ldr r1, [r1]
	add r1, r4, r1
	strb r0, [r1]
@   print_string(out); newline()
	mov r1, #128
	mov r0, r4
	bl print_string
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _out, 128, 4
	.comm _i, 4, 4
	.data
g1:
	.byte 72, 101, 108, 108, 111, 44, 32, 119, 111, 114
	.byte 108, 100, 33, 42
	.byte 0
@ End
]]*)
