(* Another version of phone book using a record type *)

type string = array 10 of char;

type rec = record name: string; age: integer end;

var 
  db: array 20 of rec;
  N: integer;

proc equal(x, y: string): boolean;
  var i: integer;
begin
  i := 0;
  while i < 10 do
    if x[i] <> y[i] then
      return false
    end;
    i := i+1
  end;
  return true
end;

proc store(n: string; a: integer);
begin
  db[N].name := n;
  db[N].age := a;
  N := N+1
end;

proc recall(n: string): integer;
  var i: integer;
begin
  i := 0;
  while i < N do
    if equal(db[i].name, n) then
      return db[i].age
    end;
    i := i+1
  end;
  return 999
end;

begin
  N := 0;

  store("bill      ", 23);
  store("george    ", 34);

  print_num(recall("george    ")); newline();
  print_num(recall("fred      ")); newline()
end.

(*<<
34
999
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc equal(x, y: string): boolean;
	.text
_equal:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   i := 0;
	mov r4, #0
.L6:
@   while i < 10 do
	cmp r4, #10
	bge .L8
@     if x[i] <> y[i] then
	ldr r0, [fp, #40]
	add r0, r0, r4
	ldrb r0, [r0]
	ldr r1, [fp, #44]
	add r1, r1, r4
	ldrb r1, [r1]
	cmp r0, r1
	beq .L11
@       return false
	mov r0, #0
	b .L5
.L11:
@     i := i+1
	add r4, r4, #1
	b .L6
.L8:
@   return true
	mov r0, #1
.L5:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc store(n: string; a: integer);
_store:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   db[N].name := n;
	mov r2, #10
	ldr r1, [fp, #40]
	set r0, _db
	set r3, _N
	ldr r3, [r3]
	lsl r3, r3, #4
	add r0, r0, r3
	bl memcpy
@   db[N].age := a;
	set r4, _N
	ldr r0, [fp, #44]
	set r1, _db
	ldr r2, [r4]
	lsl r2, r2, #4
	add r1, r1, r2
	str r0, [r1, #12]
@   N := N+1
	ldr r0, [r4]
	add r0, r0, #1
	str r0, [r4]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc recall(n: string): integer;
_recall:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   i := 0;
	mov r4, #0
.L14:
@   while i < N do
	set r0, _N
	ldr r0, [r0]
	cmp r4, r0
	bge .L16
@     if equal(db[i].name, n) then
	ldr r1, [fp, #40]
	set r0, _db
	lsl r2, r4, #4
	add r0, r0, r2
	bl _equal
	cmp r0, #0
	beq .L19
@       return db[i].age
	set r0, _db
	lsl r1, r4, #4
	add r0, r0, r1
	ldr r0, [r0, #12]
	b .L13
.L19:
@     i := i+1
	add r4, r4, #1
	b .L14
.L16:
@   return 999
	set r0, #999
.L13:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   N := 0;
	mov r0, #0
	set r1, _N
	str r0, [r1]
@   store("bill      ", 23);
	mov r1, #23
	set r0, g1
	bl _store
@   store("george    ", 34);
	mov r1, #34
	set r0, g2
	bl _store
@   print_num(recall("george    ")); newline();
	set r0, g3
	bl _recall
	bl print_num
	bl newline
@   print_num(recall("fred      ")); newline()
	set r0, g4
	bl _recall
	bl print_num
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _db, 320, 4
	.comm _N, 4, 4
	.data
g1:
	.byte 98, 105, 108, 108, 32, 32, 32, 32, 32, 32
	.byte 0
g2:
	.byte 103, 101, 111, 114, 103, 101, 32, 32, 32, 32
	.byte 0
g3:
	.byte 103, 101, 111, 114, 103, 101, 32, 32, 32, 32
	.byte 0
g4:
	.byte 102, 114, 101, 100, 32, 32, 32, 32, 32, 32
	.byte 0
@ End
]]*)
