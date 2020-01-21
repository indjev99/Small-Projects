(* Sudoku solved with Knuth's dancing links *)

(* The Boolean matrix has:

  * 81 columns Q11 .. Q99, one for each cell, since each cell must
    contain exactly one digit.

  * Nine columns Cn1 .. Cn9 for each column n of the puzzle grid, since
    each column must contain each digit exactly once.

  * Nine columns Rn1 .. Rn9 for each row of the puzzle grid.

  * Nine columns Bn1 .. Bn9 for each block of the puzzle grid.

Each row corresponds to placing a digit in a single cell, and contains
four 1's, one in each of the four groups of columns above. *)

type 
  Cell = pointer to CellRec;
  Column = pointer to ColRec;

  CellRec = record 
      up, down, left, right: Cell; 	(* Neighbours *)
      column: Column;			(* Top of the column *)
    end;

  ColRec = record
      name: char;			(* Column code: C, R, B, Q *)
      x, y: integer;			(* Two digits to identify column *)
      size: integer;			(* No. of intersecting rows *)
      covered: boolean;			(* Whether covered *)
      prev, next: Column;		(* Links to adjacent columns *)
      head: Cell;			(* Dummy node for this column *)
    end;

var 
  root: Column; 			(* Root of the entire matrix *)

(* |PrintCol| -- print the name of a column *)
proc PrintCol(c: Column);
begin
  print_char(c^.name); print_num(c^.x); print_num(c^.y)
end (* PrintCol *);
    
(* |PrintRow| -- print all columns in a given row *)
proc PrintRow(p: Cell);
  var q: Cell; n: integer; 
begin
  (* Print the columns that intersect the row *)
  q := p;
  repeat
    print_string(" "); PrintCol(q^.column); q := q^.right
  until q = p;

  (* Print position in column *)
  n := 0; q := p^.column^.head;
  while q <> p do n := n+1; q := q^.down end;
  print_string("; # "); print_num(n); print_string(" of ");
  print_num(p^.column^.size); print_string(" choices for ");
  PrintCol(p^.column); newline()
end (* PrintRow *);


(* Creating the puzzle *)

const sqrtN = 3; N = sqrtN * sqrtN;

var
  boardCell: array N of array N of Column;
  boardColumn: array N of array N of Column;
  boardRow: array N of array N of Column;
  boardBlock: array N of array N of Column;
  boardMove: array N of array N of array N of Cell;

proc ColumnLink(r: Column; var p: Cell);
  var q: Cell;
begin
  new(q);
  if p = nil then
    q^.right := q; q^.left := q; p := q
  else
    q^.left := p^.left; q^.right := p;
    p^.left^.right := q; p^.left := q
  end;
  q^.up := r^.head^.up; q^.down := r^.head;
  r^.head^.up^.down := q; r^.head^.up := q;
  q^.column := r; r^.size := r^.size+1
end (* ColumnLink *);

proc MakeArray(var a: array N of array N of Column; 
	            name: char; m, n: integer);
  var 
    i, j: integer;
    p: Column;
begin
  for i := 0 to m-1 do
    for j := 0 to n-1 do
      new(p); p^.name := name; p^.x := i+1; p^.y := j+1; 
      p^.size := 0; p^.covered := false;
      new(p^.head); p^.head^.down := p^.head; p^.head^.up := p^.head;
      p^.prev := root^.prev; p^.next := root;
      root^.prev^.next := p; root^.prev := p;
      a[i][j] := p
    end
  end
end (* MakeArray *);

proc MakeMove(i, j, k: integer);
  var p: Cell;
begin
  p := nil;
  ColumnLink(boardCell[i][j], p);
  ColumnLink(boardColumn[j][k], p);
  ColumnLink(boardRow[i][k], p);
  ColumnLink(boardBlock[sqrtN * (i div sqrtN) + j div sqrtN][k], p);
  boardMove[i][j][k] := p
end (* MakeMove *);

proc MakePuzzle();
  var i, j, k: integer;
begin
  new(root);
  root^.prev := root; root^.next := root;

  MakeArray(boardCell, 'Q', N, N);
  MakeArray(boardColumn, 'C', N, N);
  MakeArray(boardRow, 'R', N, N);
  MakeArray(boardBlock, 'B', N, N);

  for i := 0 to N-1 do
    for j := 0 to N-1 do
      for k := 0 to N-1 do
        MakeMove(i, j, k);
      end
    end
  end
end (* MakePuzzle *);  


(* Exact cover problem *)

var 
  choice: array N*N of Cell; 	(* Current set of choices *)
	
(* |Cover| -- temporarily remove a column *)
proc Cover(p: Column);
  var q, r: Cell;
begin
  p^.covered := true;

  (* Remove p from the list of columns *)
  p^.prev^.next := p^.next; p^.next^.prev := p^.prev;

  (* Block each row that intersects p *)
  q := p^.head^.down;
  while q <> p^.head do
    r := q^.right;
    while r <> q do
      r^.up^.down := r^.down; r^.down^.up := r^.up;
      r^.column^.size := r^.column^.size-1; r := r^.right
    end;
    q := q^.down
  end
end (* Cover *);

(* |Uncover| -- reverse the effect of |Cover| *)
proc Uncover(p: Column);
  var q, r: Cell;
begin
  (* Restore p to the list of columns *)
  p^.prev^.next := p; p^.next^.prev := p;

  (* Unblock each row that intersects p *)
  q := p^.head^.up;
  while q <> p^.head do
    r := q^.left;
    while r <> q do
      r^.up^.down := r; r^.down^.up := r;
      r^.column^.size := r^.column^.size+1; r := r^.left
    end;
    q := q^.up
  end;

  p^.covered := false
end (* Uncover *);

(* |ChooseColumn| -- select a column according to stratregy *)
proc ChooseColumn(): Column;
  var c, col: Column;
begin
  (* Find smallest column |col| *)
  col := root^.next;
  c := col^.next;
  while c <> root do
    if c^.size < col^.size then col := c end;
    c := c^.next
  end;
  return col
end (* ChooseColumn *);

proc PrintState(level: integer);
  var 
    i, j, k: integer; 
    p: Cell;
    board: array N of array N of char;
begin
  for i := 0 to N-1 do
    for j := 0 to N-1 do
      board[i][j] := '.'
    end
  end;

  for k := 0 to level-1 do
    p := choice[k];
    while p^.column^.name <> 'Q' do p := p^.right end;
    i := p^.column^.x - 1; j := p^.column^.y - 1;
    board[i][j] := chr(p^.right^.column^.y + ord('0'))
  end;

  for i := 0 to N-1 do
    print_string(board[i]); newline()
  end
end (* PrintState *);

(* |Solve| -- find an exact cover by backtracking search *)
proc Solve(level: integer);
  var col: Column; p, q: Cell;
begin
  if root^.next = root then
    print_string("Solution:"); newline();
    PrintState(level); return
  end;

  col := ChooseColumn();
  if col^.size = 0 then return end;
  Cover(col);

  (* Try each row that intersects column col *)
  p := col^.head^.down;
  while p <> col^.head do
    choice[level] := p;

    print_num(level); print_string(":"); PrintRow(p);

    (* Cover other columns in row |p| *)
    q := p^.right;
    while q <> p do Cover(q^.column); q := q^.right end;

    Solve(level+1);

    (* Uncover other columns in row |p| *)
    q := p^.left;
    while q <> p do Uncover(q^.column); q := q^.left end;

    p := p^.down
  end;

  Uncover(col)
end (* Solve *);

proc ChooseRow(var level: integer; p: Cell);
  var q: Cell;
begin
  choice[level] := p; level := level+1;
  q := p;
  repeat
    if q^.column^.covered then
      print_string("Conflict for "); PrintCol(q^.column); newline()
    end;
    Cover(q^.column); q := q^.right
  until q = p
end (* ChooseRow *);

const input =
"..3....51/5.2..64../..7.5..../...63.7../2..7.8..6/..4.21.../....7.8../..81..6.9/17....5..";

proc Input(var level: integer);
  var i, j, k: integer; ch: char;
begin
  for i := 0 to N-1 do
    for j := 0 to N-1 do
      ch := input[10*i+j];
      print_char(ch);
      if ch <> '.' then
        k := ord(ch) - ord('1');
	ChooseRow(level, boardMove[i][j][k])
      end
    end;
    newline()
  end
end (* Input *);

(* Main program *)
var level: integer;

begin
  MakePuzzle();
  level := 0;
  Input(level);
  Solve(level)
end (* tSudoku *).

(*<<
..3....51
5.2..64..
..7.5....
...63.7..
2..7.8..6
..4.21...
....7.8..
..81..6.9
17....5..
28: Q85 C54 R84 B84; # 1 of 1 choices for Q85
29: Q55 C59 R59 B59; # 1 of 1 choices for Q55
30: Q15 C58 R18 B28; # 1 of 1 choices for Q15
31: Q25 C51 R21 B21; # 1 of 1 choices for Q25
32: Q64 C45 R65 B55; # 1 of 1 choices for Q64
33: Q46 C64 R44 B54; # 1 of 1 choices for Q46
34: Q81 C13 R83 B73; # 1 of 1 choices for Q81
35: Q95 C56 R96 B86; # 1 of 1 choices for Q95
36: Q93 C39 R99 B79; # 1 of 1 choices for Q93
37: C17 R67 B47 Q61; # 1 of 1 choices for C17
38: C36 R76 B76 Q73; # 1 of 1 choices for C36
39: Q71 C14 R74 B74; # 1 of 1 choices for Q71
40: C48 R98 B88 Q94; # 1 of 1 choices for C48
41: C67 R17 B27 Q16; # 1 of 1 choices for C67
42: C71 R51 B61 Q57; # 1 of 1 choices for C71
43: Q53 C35 R55 B45; # 1 of 1 choices for Q53
44: Q43 C31 R41 B41; # 1 of 1 choices for Q43
45: Q52 C23 R53 B43; # 1 of 1 choices for Q52
46: Q58 C84 R54 B64; # 1 of 1 choices for Q58
47: C21 R31 B11 Q32; # 1 of 1 choices for C21
48: C24 R14 B14 Q12; # 1 of 1 choices for C24
49: C26 R66 B46 Q62; # 1 of 1 choices for C26
50: C44 R34 B24 Q34; # 1 of 1 choices for C44
51: C81 R71 B91 Q78; # 1 of 1 choices for C81
52: C86 R36 B36 Q38; # 1 of 1 choices for C86
53: C16 R16 B16 Q11; # 1 of 1 choices for C16
54: C94 R94 B94 Q99; # 1 of 1 choices for C94
55: C95 R45 B65 Q49; # 1 of 1 choices for C95
56: C97 R27 B37 Q29; # 1 of 1 choices for C97
57: C87 R87 B97 Q88; # 1 of 1 choices for C87
58: R42 B62 Q48 C82; # 1 of 1 choices for R42
59: Q98 C83 R93 B93; # 1 of 1 choices for Q98
60: Q79 C92 R72 B92; # 1 of 1 choices for Q79
61: Q72 C25 R75 B75; # 1 of 1 choices for Q72
62: Q82 C22 R82 B72; # 1 of 1 choices for Q82
63: Q86 C65 R85 B85; # 1 of 1 choices for Q86
64: Q96 C62 R92 B82; # 1 of 1 choices for Q96
65: C42 R12 B22 Q14; # 1 of 1 choices for C42
66: Q17 C79 R19 B39; # 1 of 1 choices for Q17
67: Q28 C88 R28 B38; # 1 of 1 choices for Q28
68: Q22 C29 R29 B19; # 1 of 1 choices for Q22
69: Q24 C43 R23 B23; # 1 of 1 choices for Q24
70: Q31 C18 R38 B18; # 1 of 1 choices for Q31
71: Q36 C69 R39 B29; # 1 of 1 choices for Q36
72: Q39 C93 R33 B33; # 1 of 1 choices for Q39
73: Q37 C72 R32 B32; # 1 of 1 choices for Q37
74: Q41 C19 R49 B49; # 1 of 1 choices for Q41
75: Q42 C28 R48 B48; # 1 of 1 choices for Q42
76: Q67 C73 R63 B63; # 1 of 1 choices for Q67
77: Q68 C89 R69 B69; # 1 of 1 choices for Q68
78: Q69 C98 R68 B68; # 1 of 1 choices for Q69
79: Q74 C49 R79 B89; # 1 of 1 choices for Q74
80: Q76 C63 R73 B83; # 1 of 1 choices for Q76
Solution:
643287951
592316487
817459263
981634725
235798146
764521398
456973812
328145679
179862534
>>*)

(*[[
@ picoPascal compiler output
	.include "fixup.s"
	.global pmain

@ proc PrintCol(c: Column);
	.text
_PrintCol:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   print_char(c^.name); print_num(c^.x); print_num(c^.y)
	ldr r0, [fp, #40]
	ldrb r0, [r0]
	bl print_char
	ldr r0, [fp, #40]
	ldr r0, [r0, #4]
	bl print_num
	ldr r0, [fp, #40]
	ldr r0, [r0, #8]
	bl print_num
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc PrintRow(p: Cell);
_PrintRow:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   q := p;
	ldr r4, [fp, #40]
.L11:
@     print_string(" "); PrintCol(q^.column); q := q^.right
	mov r1, #1
	set r0, g1
	bl print_string
	ldr r0, [r4, #16]
	bl _PrintCol
	ldr r4, [r4, #12]
	ldr r6, [fp, #40]
	cmp r4, r6
	bne .L11
@   n := 0; q := p^.column^.head;
	mov r5, #0
	ldr r0, [r6, #16]
	ldr r4, [r0, #28]
.L13:
@   while q <> p do n := n+1; q := q^.down end;
	ldr r0, [fp, #40]
	cmp r4, r0
	beq .L15
	add r5, r5, #1
	ldr r4, [r4, #4]
	b .L13
.L15:
@   print_string("; # "); print_num(n); print_string(" of ");
	mov r1, #4
	set r0, g2
	bl print_string
	mov r0, r5
	bl print_num
	mov r1, #4
	set r0, g3
	bl print_string
@   print_num(p^.column^.size); print_string(" choices for ");
	ldr r0, [fp, #40]
	ldr r0, [r0, #16]
	ldr r0, [r0, #12]
	bl print_num
	mov r1, #13
	set r0, g4
	bl print_string
@   PrintCol(p^.column); newline()
	ldr r0, [fp, #40]
	ldr r0, [r0, #16]
	bl _PrintCol
	bl newline
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc ColumnLink(r: Column; var p: Cell);
_ColumnLink:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   new(q);
	mov r0, #20
	bl new
	mov r4, r0
@   if p = nil then
	ldr r0, [fp, #44]
	ldr r0, [r0]
	cmp r0, #0
	bne .L18
@     q^.right := q; q^.left := q; p := q
	str r4, [r4, #12]
	str r4, [r4, #8]
	ldr r0, [fp, #44]
	str r4, [r0]
	b .L19
.L18:
@     q^.left := p^.left; q^.right := p;
	ldr r0, [fp, #44]
	ldr r0, [r0]
	ldr r0, [r0, #8]
	str r0, [r4, #8]
	ldr r0, [fp, #44]
	ldr r0, [r0]
	str r0, [r4, #12]
@     p^.left^.right := q; p^.left := q
	ldr r0, [fp, #44]
	ldr r0, [r0]
	ldr r0, [r0, #8]
	str r4, [r0, #12]
	ldr r0, [fp, #44]
	ldr r0, [r0]
	str r4, [r0, #8]
.L19:
@   q^.up := r^.head^.up; q^.down := r^.head;
	ldr r0, [fp, #40]
	ldr r0, [r0, #28]
	ldr r0, [r0]
	str r0, [r4]
	ldr r0, [fp, #40]
	ldr r0, [r0, #28]
	str r0, [r4, #4]
@   r^.head^.up^.down := q; r^.head^.up := q;
	ldr r0, [fp, #40]
	ldr r0, [r0, #28]
	ldr r0, [r0]
	str r4, [r0, #4]
	ldr r0, [fp, #40]
	ldr r0, [r0, #28]
	str r4, [r0]
@   q^.column := r; r^.size := r^.size+1
	ldr r0, [fp, #40]
	str r0, [r4, #16]
	ldr r0, [fp, #40]
	add r5, r0, #12
	ldr r0, [r5]
	add r0, r0, #1
	str r0, [r5]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc MakeArray(var a: array N of array N of Column; 
_MakeArray:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	sub sp, sp, #8
@   for i := 0 to m-1 do
	mov r4, #0
	ldr r0, [fp, #48]
	sub r0, r0, #1
	str r0, [fp, #-8]
.L21:
	ldr r0, [fp, #-8]
	cmp r4, r0
	bgt .L20
@     for j := 0 to n-1 do
	mov r5, #0
	ldr r0, [fp, #52]
	sub r0, r0, #1
	str r0, [fp, #-4]
.L23:
	ldr r0, [fp, #-4]
	cmp r5, r0
	bgt .L24
@       new(p); p^.name := name; p^.x := i+1; p^.y := j+1; 
	mov r0, #32
	bl new
	mov r6, r0
	ldrb r0, [fp, #44]
	strb r0, [r6]
	add r0, r4, #1
	str r0, [r6, #4]
	add r0, r5, #1
	str r0, [r6, #8]
@       p^.size := 0; p^.covered := false;
	mov r0, #0
	str r0, [r6, #12]
	mov r0, #0
	strb r0, [r6, #16]
@       new(p^.head); p^.head^.down := p^.head; p^.head^.up := p^.head;
	mov r0, #20
	bl new
	str r0, [r6, #28]
	ldr r7, [r6, #28]
	str r7, [r7, #4]
	ldr r7, [r6, #28]
	str r7, [r7]
@       p^.prev := root^.prev; p^.next := root;
	set r7, _root
	ldr r0, [r7]
	ldr r0, [r0, #20]
	str r0, [r6, #20]
	ldr r0, [r7]
	str r0, [r6, #24]
@       root^.prev^.next := p; root^.prev := p;
	ldr r0, [r7]
	ldr r0, [r0, #20]
	str r6, [r0, #24]
	ldr r0, [r7]
	str r6, [r0, #20]
@       a[i][j] := p
	ldr r0, [fp, #40]
	mov r1, #36
	mul r1, r4, r1
	add r0, r0, r1
	lsl r1, r5, #2
	add r0, r0, r1
	str r6, [r0]
	add r5, r5, #1
	b .L23
.L24:
	add r4, r4, #1
	b .L21
.L20:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc MakeMove(i, j, k: integer);
_MakeMove:
	mov ip, sp
	stmfd sp!, {r0-r3}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	sub sp, sp, #8
@   p := nil;
	mov r0, #0
	str r0, [fp, #-4]
@   ColumnLink(boardCell[i][j], p);
	add r1, fp, #-4
	set r0, _boardCell
	ldr r2, [fp, #40]
	mov r3, #36
	mul r2, r2, r3
	add r0, r0, r2
	ldr r2, [fp, #44]
	lsl r2, r2, #2
	add r0, r0, r2
	ldr r0, [r0]
	bl _ColumnLink
@   ColumnLink(boardColumn[j][k], p);
	add r1, fp, #-4
	set r0, _boardColumn
	ldr r2, [fp, #44]
	mov r3, #36
	mul r2, r2, r3
	add r0, r0, r2
	ldr r2, [fp, #48]
	lsl r2, r2, #2
	add r0, r0, r2
	ldr r0, [r0]
	bl _ColumnLink
@   ColumnLink(boardRow[i][k], p);
	add r1, fp, #-4
	set r0, _boardRow
	ldr r2, [fp, #40]
	mov r3, #36
	mul r2, r2, r3
	add r0, r0, r2
	ldr r2, [fp, #48]
	lsl r2, r2, #2
	add r0, r0, r2
	ldr r0, [r0]
	bl _ColumnLink
@   ColumnLink(boardBlock[sqrtN * (i div sqrtN) + j div sqrtN][k], p);
	mov r1, #3
	ldr r0, [fp, #40]
	bl int_div
	mov r1, #3
	mov r4, r0
	ldr r0, [fp, #44]
	bl int_div
	add r1, fp, #-4
	mov r5, r0
	set r0, _boardBlock
	mov r2, #3
	mul r2, r4, r2
	add r2, r2, r5
	mov r3, #36
	mul r2, r2, r3
	add r0, r0, r2
	ldr r2, [fp, #48]
	lsl r2, r2, #2
	add r0, r0, r2
	ldr r0, [r0]
	bl _ColumnLink
@   boardMove[i][j][k] := p
	ldr r0, [fp, #-4]
	set r1, _boardMove
	ldr r2, [fp, #40]
	mov r3, #324
	mul r2, r2, r3
	add r1, r1, r2
	ldr r2, [fp, #44]
	mov r3, #36
	mul r2, r2, r3
	add r1, r1, r2
	ldr r2, [fp, #48]
	lsl r2, r2, #2
	add r1, r1, r2
	str r0, [r1]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc MakePuzzle();
_MakePuzzle:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	sub sp, sp, #16
@   new(root);
	mov r0, #32
	bl new
	set r7, _root
	str r0, [r7]
@   root^.prev := root; root^.next := root;
	str r0, [r0, #20]
	ldr r7, [r7]
	str r7, [r7, #24]
@   MakeArray(boardCell, 'Q', N, N);
	mov r3, #9
	mov r2, #9
	mov r1, #81
	set r0, _boardCell
	bl _MakeArray
@   MakeArray(boardColumn, 'C', N, N);
	mov r3, #9
	mov r2, #9
	mov r1, #67
	set r0, _boardColumn
	bl _MakeArray
@   MakeArray(boardRow, 'R', N, N);
	mov r3, #9
	mov r2, #9
	mov r1, #82
	set r0, _boardRow
	bl _MakeArray
@   MakeArray(boardBlock, 'B', N, N);
	mov r3, #9
	mov r2, #9
	mov r1, #66
	set r0, _boardBlock
	bl _MakeArray
@   for i := 0 to N-1 do
	mov r4, #0
	mov r0, #8
	str r0, [fp, #-12]
.L27:
	ldr r0, [fp, #-12]
	cmp r4, r0
	bgt .L26
@     for j := 0 to N-1 do
	mov r5, #0
	mov r0, #8
	str r0, [fp, #-8]
.L29:
	ldr r0, [fp, #-8]
	cmp r5, r0
	bgt .L30
@       for k := 0 to N-1 do
	mov r6, #0
	mov r0, #8
	str r0, [fp, #-4]
.L31:
	ldr r0, [fp, #-4]
	cmp r6, r0
	bgt .L32
@         MakeMove(i, j, k);
	mov r2, r6
	mov r1, r5
	mov r0, r4
	bl _MakeMove
@       end
	add r6, r6, #1
	b .L31
.L32:
	add r5, r5, #1
	b .L29
.L30:
	add r4, r4, #1
	b .L27
.L26:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc Cover(p: Column);
_Cover:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   p^.covered := true;
	mov r0, #1
	ldr r1, [fp, #40]
	strb r0, [r1, #16]
@   p^.prev^.next := p^.next; p^.next^.prev := p^.prev;
	ldr r6, [fp, #40]
	ldr r0, [r6, #24]
	ldr r1, [r6, #20]
	str r0, [r1, #24]
	ldr r6, [fp, #40]
	ldr r0, [r6, #20]
	ldr r1, [r6, #24]
	str r0, [r1, #20]
@   q := p^.head^.down;
	ldr r0, [fp, #40]
	ldr r0, [r0, #28]
	ldr r4, [r0, #4]
.L34:
@   while q <> p^.head do
	ldr r0, [fp, #40]
	ldr r0, [r0, #28]
	cmp r4, r0
	beq .L33
@     r := q^.right;
	ldr r5, [r4, #12]
.L37:
@     while r <> q do
	cmp r5, r4
	beq .L39
@       r^.up^.down := r^.down; r^.down^.up := r^.up;
	ldr r0, [r5, #4]
	ldr r1, [r5]
	str r0, [r1, #4]
	ldr r0, [r5]
	ldr r1, [r5, #4]
	str r0, [r1]
@       r^.column^.size := r^.column^.size-1; r := r^.right
	ldr r0, [r5, #16]
	add r6, r0, #12
	ldr r0, [r6]
	sub r0, r0, #1
	str r0, [r6]
	ldr r5, [r5, #12]
	b .L37
.L39:
@     q := q^.down
	ldr r4, [r4, #4]
	b .L34
.L33:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc Uncover(p: Column);
_Uncover:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   p^.prev^.next := p; p^.next^.prev := p;
	ldr r6, [fp, #40]
	ldr r0, [r6, #20]
	str r6, [r0, #24]
	ldr r6, [fp, #40]
	ldr r0, [r6, #24]
	str r6, [r0, #20]
@   q := p^.head^.up;
	ldr r0, [fp, #40]
	ldr r0, [r0, #28]
	ldr r4, [r0]
.L41:
@   while q <> p^.head do
	ldr r0, [fp, #40]
	ldr r0, [r0, #28]
	cmp r4, r0
	beq .L43
@     r := q^.left;
	ldr r5, [r4, #8]
.L44:
@     while r <> q do
	cmp r5, r4
	beq .L46
@       r^.up^.down := r; r^.down^.up := r;
	ldr r0, [r5]
	str r5, [r0, #4]
	ldr r0, [r5, #4]
	str r5, [r0]
@       r^.column^.size := r^.column^.size+1; r := r^.left
	ldr r0, [r5, #16]
	add r6, r0, #12
	ldr r0, [r6]
	add r0, r0, #1
	str r0, [r6]
	ldr r5, [r5, #8]
	b .L44
.L46:
@     q := q^.up
	ldr r4, [r4]
	b .L41
.L43:
@   p^.covered := false
	mov r0, #0
	ldr r1, [fp, #40]
	strb r0, [r1, #16]
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc ChooseColumn(): Column;
_ChooseColumn:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   col := root^.next;
	set r0, _root
	ldr r0, [r0]
	ldr r5, [r0, #24]
@   c := col^.next;
	ldr r4, [r5, #24]
.L48:
@   while c <> root do
	set r0, _root
	ldr r0, [r0]
	cmp r4, r0
	beq .L50
@     if c^.size < col^.size then col := c end;
	ldr r0, [r4, #12]
	ldr r1, [r5, #12]
	cmp r0, r1
	bge .L53
	mov r5, r4
.L53:
@     c := c^.next
	ldr r4, [r4, #24]
	b .L48
.L50:
@   return col
	mov r0, r5
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc PrintState(level: integer);
_PrintState:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	sub sp, sp, #104
@   for i := 0 to N-1 do
	mov r4, #0
	mov r0, #8
	str r0, [fp, #-96]
.L55:
	ldr r0, [fp, #-96]
	cmp r4, r0
	bgt .L56
@     for j := 0 to N-1 do
	mov r5, #0
	mov r0, #8
	str r0, [fp, #-92]
.L57:
	ldr r0, [fp, #-92]
	cmp r5, r0
	bgt .L58
@       board[i][j] := '.'
	mov r0, #46
	add r1, fp, #-85
	mov r2, #9
	mul r2, r4, r2
	add r1, r1, r2
	add r1, r1, r5
	strb r0, [r1]
	add r5, r5, #1
	b .L57
.L58:
	add r4, r4, #1
	b .L55
.L56:
@   for k := 0 to level-1 do
	mov r6, #0
	ldr r0, [fp, #40]
	sub r0, r0, #1
	str r0, [fp, #-100]
.L59:
	ldr r0, [fp, #-100]
	cmp r6, r0
	bgt .L60
@     p := choice[k];
	set r0, _choice
	lsl r1, r6, #2
	add r0, r0, r1
	ldr r0, [r0]
	str r0, [fp, #-4]
.L61:
@     while p^.column^.name <> 'Q' do p := p^.right end;
	ldr r7, [fp, #-4]
	ldr r0, [r7, #16]
	ldrb r0, [r0]
	cmp r0, #81
	beq .L63
	ldr r0, [r7, #12]
	str r0, [fp, #-4]
	b .L61
.L63:
@     i := p^.column^.x - 1; j := p^.column^.y - 1;
	ldr r7, [fp, #-4]
	ldr r8, [r7, #16]
	ldr r0, [r8, #4]
	sub r4, r0, #1
	ldr r0, [r8, #8]
	sub r5, r0, #1
@     board[i][j] := chr(p^.right^.column^.y + ord('0'))
	ldr r0, [r7, #12]
	ldr r0, [r0, #16]
	ldr r0, [r0, #8]
	add r0, r0, #48
	add r1, fp, #-85
	mov r2, #9
	mul r2, r4, r2
	add r1, r1, r2
	add r1, r1, r5
	strb r0, [r1]
	add r6, r6, #1
	b .L59
.L60:
@   for i := 0 to N-1 do
	mov r4, #0
	mov r0, #8
	str r0, [fp, #-104]
.L64:
	ldr r0, [fp, #-104]
	cmp r4, r0
	bgt .L54
@     print_string(board[i]); newline()
	mov r1, #9
	add r0, fp, #-85
	mov r2, #9
	mul r2, r4, r2
	add r0, r0, r2
	bl print_string
	bl newline
	add r4, r4, #1
	b .L64
.L54:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc Solve(level: integer);
_Solve:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   if root^.next = root then
	set r0, _root
	ldr r7, [r0]
	ldr r0, [r7, #24]
	cmp r0, r7
	bne .L69
@     print_string("Solution:"); newline();
	mov r1, #9
	set r0, g5
	bl print_string
	bl newline
@     PrintState(level); return
	ldr r0, [fp, #40]
	bl _PrintState
	b .L66
.L69:
@   col := ChooseColumn();
	bl _ChooseColumn
	mov r4, r0
@   if col^.size = 0 then return end;
	ldr r0, [r4, #12]
	cmp r0, #0
	beq .L66
@   Cover(col);
	mov r0, r4
	bl _Cover
@   p := col^.head^.down;
	ldr r0, [r4, #28]
	ldr r5, [r0, #4]
.L73:
@   while p <> col^.head do
	ldr r0, [r4, #28]
	cmp r5, r0
	beq .L75
@     choice[level] := p;
	ldr r7, [fp, #40]
	set r0, _choice
	lsl r1, r7, #2
	add r0, r0, r1
	str r5, [r0]
@     print_num(level); print_string(":"); PrintRow(p);
	mov r0, r7
	bl print_num
	mov r1, #1
	set r0, g6
	bl print_string
	mov r0, r5
	bl _PrintRow
@     q := p^.right;
	ldr r6, [r5, #12]
.L76:
@     while q <> p do Cover(q^.column); q := q^.right end;
	cmp r6, r5
	beq .L78
	ldr r0, [r6, #16]
	bl _Cover
	ldr r6, [r6, #12]
	b .L76
.L78:
@     Solve(level+1);
	ldr r0, [fp, #40]
	add r0, r0, #1
	bl _Solve
@     q := p^.left;
	ldr r6, [r5, #8]
.L79:
@     while q <> p do Uncover(q^.column); q := q^.left end;
	cmp r6, r5
	beq .L81
	ldr r0, [r6, #16]
	bl _Uncover
	ldr r6, [r6, #8]
	b .L79
.L81:
@     p := p^.down
	ldr r5, [r5, #4]
	b .L73
.L75:
@   Uncover(col)
	mov r0, r4
	bl _Uncover
.L66:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc ChooseRow(var level: integer; p: Cell);
_ChooseRow:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   choice[level] := p; level := level+1;
	ldr r5, [fp, #40]
	ldr r0, [fp, #44]
	set r1, _choice
	ldr r2, [r5]
	lsl r2, r2, #2
	add r1, r1, r2
	str r0, [r1]
	ldr r0, [r5]
	add r0, r0, #1
	str r0, [r5]
@   q := p;
	ldr r4, [fp, #44]
.L83:
@     if q^.column^.covered then
	ldr r0, [r4, #16]
	ldrb r0, [r0, #16]
	cmp r0, #0
	beq .L87
@       print_string("Conflict for "); PrintCol(q^.column); newline()
	mov r1, #13
	set r0, g7
	bl print_string
	ldr r0, [r4, #16]
	bl _PrintCol
	bl newline
.L87:
@     Cover(q^.column); q := q^.right
	ldr r0, [r4, #16]
	bl _Cover
	ldr r4, [r4, #12]
	ldr r0, [fp, #44]
	cmp r4, r0
	bne .L83
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

@ proc Input(var level: integer);
_Input:
	mov ip, sp
	stmfd sp!, {r0-r1}
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
	sub sp, sp, #16
@   for i := 0 to N-1 do
	mov r4, #0
	mov r0, #8
	str r0, [fp, #-12]
.L89:
	ldr r0, [fp, #-12]
	cmp r4, r0
	bgt .L88
@     for j := 0 to N-1 do
	mov r5, #0
	mov r0, #8
	str r0, [fp, #-8]
.L91:
	ldr r0, [fp, #-8]
	cmp r5, r0
	bgt .L92
@       ch := input[10*i+j];
	set r0, g8
	mov r1, #10
	mul r1, r4, r1
	add r0, r0, r1
	add r0, r0, r5
	ldrb r7, [r0]
	strb r7, [fp, #-1]
@       print_char(ch);
	mov r0, r7
	bl print_char
@       if ch <> '.' then
	ldrb r7, [fp, #-1]
	cmp r7, #46
	beq .L95
@         k := ord(ch) - ord('1');
	sub r6, r7, #49
@ 	ChooseRow(level, boardMove[i][j][k])
	set r0, _boardMove
	mov r1, #324
	mul r1, r4, r1
	add r0, r0, r1
	mov r1, #36
	mul r1, r5, r1
	add r0, r0, r1
	lsl r1, r6, #2
	add r0, r0, r1
	ldr r1, [r0]
	ldr r0, [fp, #40]
	bl _ChooseRow
.L95:
	add r5, r5, #1
	b .L91
.L92:
@     newline()
	bl newline
	add r4, r4, #1
	b .L89
.L88:
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

pmain:
	mov ip, sp
	stmfd sp!, {r4-r10, fp, ip, lr}
	mov fp, sp
@   MakePuzzle();
	bl _MakePuzzle
@   level := 0;
	set r4, _level
	mov r0, #0
	str r0, [r4]
@   Input(level);
	mov r0, r4
	bl _Input
@   Solve(level)
	set r0, _level
	ldr r0, [r0]
	bl _Solve
	ldmfd fp, {r4-r10, fp, sp, pc}
	.ltorg

	.comm _root, 4, 4
	.comm _boardCell, 324, 4
	.comm _boardColumn, 324, 4
	.comm _boardRow, 324, 4
	.comm _boardBlock, 324, 4
	.comm _boardMove, 2916, 4
	.comm _choice, 324, 4
	.comm _level, 4, 4
	.data
g1:
	.byte 32
	.byte 0
g2:
	.byte 59, 32, 35, 32
	.byte 0
g3:
	.byte 32, 111, 102, 32
	.byte 0
g4:
	.byte 32, 99, 104, 111, 105, 99, 101, 115, 32, 102
	.byte 111, 114, 32
	.byte 0
g5:
	.byte 83, 111, 108, 117, 116, 105, 111, 110, 58
	.byte 0
g6:
	.byte 58
	.byte 0
g7:
	.byte 67, 111, 110, 102, 108, 105, 99, 116, 32, 102
	.byte 111, 114, 32
	.byte 0
g8:
	.byte 46, 46, 51, 46, 46, 46, 46, 53, 49, 47
	.byte 53, 46, 50, 46, 46, 54, 52, 46, 46, 47
	.byte 46, 46, 55, 46, 53, 46, 46, 46, 46, 47
	.byte 46, 46, 46, 54, 51, 46, 55, 46, 46, 47
	.byte 50, 46, 46, 55, 46, 56, 46, 46, 54, 47
	.byte 46, 46, 52, 46, 50, 49, 46, 46, 46, 47
	.byte 46, 46, 46, 46, 55, 46, 56, 46, 46, 47
	.byte 46, 46, 56, 49, 46, 46, 54, 46, 57, 47
	.byte 49, 55, 46, 46, 46, 46, 53, 46, 46
	.byte 0
@ End
]]*)
