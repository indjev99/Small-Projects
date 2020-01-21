(* N queens in functional form *)

const N = 8;

proc queens(k: integer; proc choice(x: integer): integer);
  var y, j, q: integer; ok: boolean;

  proc choice1(x: integer): integer;
  begin
    if x = k then
      return y
    else
      return choice(x)
    end;
  end;

begin
  if k > N then
    print(choice)
  else
    y := 1;
    while y <= N do
      j := 1; ok := true;
      while ok and (j < k) do
	q := choice(j);
	ok := (q <> y) and (q+j <> y+k) and (q-j <> y-k);
        j := j+1
      end;
      if ok then queens(k+1, choice1) end;
      y := y+1
    end
  end
end;

proc print(proc choice(x: integer): integer);
  var x: integer;
begin
  x := 1;
  while x <= N do
    print_num(choice(x));
    x := x+1
  end;
  newline()
end;

proc choice0(x: integer): integer;
begin
  return 0
end;

begin
  queens(1, choice0)
end.

(*<<
15863724
16837425
17468253
17582463
24683175
25713864
25741863
26174835
26831475
27368514
27581463
28613574
31758246
35281746
35286471
35714286
35841726
36258174
36271485
36275184
36418572
36428571
36814752
36815724
36824175
37285146
37286415
38471625
41582736
41586372
42586137
42736815
42736851
42751863
42857136
42861357
46152837
46827135
46831752
47185263
47382516
47526138
47531682
48136275
48157263
48531726
51468273
51842736
51863724
52468317
52473861
52617483
52814736
53168247
53172864
53847162
57138642
57142863
57248136
57263148
57263184
57413862
58413627
58417263
61528374
62713584
62714853
63175824
63184275
63185247
63571428
63581427
63724815
63728514
63741825
64158273
64285713
64713528
64718253
68241753
71386425
72418536
72631485
73168524
73825164
74258136
74286135
75316824
82417536
82531746
83162574
84136275
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc queens(k: integer; proc choice(x: integer): integer);
	.text
_queens:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	sub sp, sp, #8
@   if k > N then
	ldr r0, [fp, #40]
	cmp r0, #8
	ble .L3
@     print(choice)
	ldr r1, [fp, #48]
	ldr r0, [fp, #44]
	bl _print
	b .L1
.L3:
@     y := 1;
	mov r0, #1
	str r0, [fp, #-4]
.L5:
@     while y <= N do
	ldr r0, [fp, #-4]
	cmp r0, #8
	bgt .L1
@       j := 1; ok := true;
	mov r4, #1
	mov r6, #1
.L8:
@       while ok and (j < k) do
	cmp r6, #0
	beq .L10
	ldr r0, [fp, #40]
	cmp r4, r0
	bge .L10
@ 	q := choice(j);
	mov r0, r4
	ldr r10, [fp, #48]
	ldr r1, [fp, #44]
	blx r1
	mov r5, r0
@ 	ok := (q <> y) and (q+j <> y+k) and (q-j <> y-k);
	ldr r7, [fp, #-4]
	ldr r8, [fp, #40]
	cmp r5, r7
	mov r0, #0
	movne r0, #1
	add r1, r5, r4
	add r2, r7, r8
	cmp r1, r2
	mov r1, #0
	movne r1, #1
	and r0, r0, r1
	sub r1, r5, r4
	sub r2, r7, r8
	cmp r1, r2
	mov r1, #0
	movne r1, #1
	and r6, r0, r1
@         j := j+1
	add r4, r4, #1
	b .L8
.L10:
@       if ok then queens(k+1, choice1) end;
	cmp r6, #0
	beq .L14
	mov r2, fp
	set r1, _choice1
	ldr r0, [fp, #40]
	add r0, r0, #1
	bl _queens
.L14:
@       y := y+1
	ldr r0, [fp, #-4]
	add r0, r0, #1
	str r0, [fp, #-4]
	b .L5
.L1:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@   proc choice1(x: integer): integer;
_choice1:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@     if x = k then
	ldr r4, [fp, #24]
	ldr r0, [fp, #40]
	ldr r1, [r4, #40]
	cmp r0, r1
	bne .L17
@       return y
	ldr r0, [r4, #-4]
	b .L15
.L17:
@       return choice(x)
	ldr r4, [fp, #24]
	ldr r0, [fp, #40]
	ldr r10, [r4, #48]
	ldr r1, [r4, #44]
	blx r1
.L15:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc print(proc choice(x: integer): integer);
_print:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   x := 1;
	mov r4, #1
.L20:
@   while x <= N do
	cmp r4, #8
	bgt .L22
@     print_num(choice(x));
	mov r0, r4
	ldr r10, [fp, #44]
	ldr r1, [fp, #40]
	blx r1
	bl print_num
@     x := x+1
	add r4, r4, #1
	b .L20
.L22:
@   newline()
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc choice0(x: integer): integer;
_choice0:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   return 0
	mov r0, #0
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   queens(1, choice0)
	mov r2, #0
	set r1, _choice0
	mov r0, #1
	bl _queens
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ End
]]*)
