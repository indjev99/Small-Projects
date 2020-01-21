(* Linked lists *)

type ptr = pointer to rec;
  rec = record 
      data: integer; 
      next: ptr; 
    end;

proc sum(p: ptr): integer;
  var q: ptr; s: integer;
begin
  q := p; s := 0;
  while q <> nil do
    s := s + q^.data;
    q := q^.next
  end;
  return s
end;

proc main();
  const input = "3141592650";
  var i: integer; p, q: ptr;
begin
  i := 0;
  while input[i] <> '0' do i := i+1 end;

  p := nil;
  while i > 0 do
    i := i-1;
    q := p;
    new(p);
    p^.data := ord(input[i]) - ord('0');
    p^.next := q
  end;

  print_num(sum(p)); newline()
end;

begin
  main()
end.

(*<<
36
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc sum(p: ptr): integer;
	.text
_sum:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   q := p; s := 0;
	ldr r4, [fp, #40]
	mov r5, #0
.L3:
@   while q <> nil do
	cmp r4, #0
	beq .L5
@     s := s + q^.data;
	ldr r0, [r4]
	add r5, r5, r0
@     q := q^.next
	ldr r4, [r4, #4]
	b .L3
.L5:
@   return s
	mov r0, r5
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc main();
_main:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   i := 0;
	mov r4, #0
.L7:
@   while input[i] <> '0' do i := i+1 end;
	set r0, g1
	add r0, r0, r4
	ldrb r0, [r0]
	cmp r0, #48
	beq .L9
	add r4, r4, #1
	b .L7
.L9:
@   p := nil;
	mov r5, #0
.L10:
@   while i > 0 do
	cmp r4, #0
	ble .L12
@     i := i-1;
	sub r4, r4, #1
@     q := p;
	mov r6, r5
@     new(p);
	mov r0, #8
	bl new
	mov r5, r0
@     p^.data := ord(input[i]) - ord('0');
	set r0, g1
	add r0, r0, r4
	ldrb r0, [r0]
	sub r0, r0, #48
	str r0, [r5]
@     p^.next := q
	str r6, [r5, #4]
	b .L10
.L12:
@   print_num(sum(p)); newline()
	mov r0, r5
	bl _sum
	bl print_num
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

	.data
g1:
	.byte 51, 49, 52, 49, 53, 57, 50, 54, 53, 48
	.byte 0
@ End
]]*)
