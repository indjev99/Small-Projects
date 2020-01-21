(* lab4/tran.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Optree
open Target
open Regs
open Print

let debug = ref 0

(* |release| -- release any register used by a value *)
let release =
  function
      Register reg -> release_reg reg
    | Index (reg, off) -> release_reg reg
    | Index2 (r1, r2, n) -> release_reg r1; release_reg r2
    | Shift (reg, n) -> release_reg reg;
    | _ -> ()

let fix_reg r = Register (get_reg (reg_of r))

(* |gen_reg| -- emit instruction with result in a register *)
let gen_reg op rands =
  List.iter release (List.tl rands);
  let r' = fix_reg (List.hd rands) in
  emit op (r' :: List.tl rands);
  r'

(* |gen| -- emit an instruction *)
let gen op rands =
  List.iter release rands;
  emit op rands

(* |gen_move| -- move value to specific register *)
let gen_move dst src =
  if reg_of dst = R_any || reg_of dst = R_temp || dst = src then
    src
  else
    gen_reg "mov" [dst; src]


(* Tests for fitting in various immediate fields *)

(* |fits_offset| -- test for fitting in offset field of address *)
let fits_offset x = (-4096 < x && x < 4096)

(* |fits_immed| -- test for fitting in immediate field *)
let fits_immed x =
  (* A conservative approximation, using shifts instead of rotates *)
  let rec reduce r =
    if r land 3 <> 0 then r else reduce (r lsr 2) in
  x = 0 || x > 0 && reduce x < 256

(* |fits_move| -- test for fitting in immediate move *)
let fits_move x = fits_immed x || fits_immed (lnot x)

(* |fits_add| -- test for fitting in immediate add *)
let fits_add x = fits_immed x || fits_immed (-x)

(* |line| -- current line number *)
let line = ref 0

(* The main part of the code generator consists of a family of functions
   e_X t, each generating code for a tree t, leaving the value in
   a register, or as an operand for another instruction, etc. *)

let anyreg = Register R_any
let anytemp = Register R_temp

(* |e_reg| -- evaluate expression with result in specified register *)
let rec e_reg t r =
  (* returns |Register| *)

  (* Binary operation *)
  let binary op t1 t2 =
    let v1 = e_reg t1 anyreg in
    let v2 = e_rand t2 in
    gen_reg op [r; v1; v2]

  (* Unary operation *)
  and unary op t1 =
    let v1 = e_reg t1 anyreg in
    gen_reg op [r; v1]

  (* Comparison with boolean result *)
  and compare op t1 t2 =
    let v1 = e_reg t1 anyreg in
    let v2 = e_rand t2 in
    release v1; release v2;
    let rr = fix_reg r in
    emit "cmp" [v1; v2];
    emit "mov" [rr; Const 0];
    emit op [rr; Const 1];
    rr in

  match t with
      <CONST k> when fits_move k -> 
        gen_reg "mov" [r; Const k]
    | <CONST k> ->
        gen_reg "set" [r; Const k]
    | <LOCAL 0> ->
        gen_move r (Register R_fp)
    | <LOCAL n> when fits_add n ->
        gen_reg "add" [r; Register R_fp; Const n]
    | <LOCAL n> ->
        emit "set" [Register R_ip; Const n];
        gen_reg "add" [r; Register R_fp; Register R_ip]
    | <GLOBAL x> ->
        gen_reg "set" [r; Global x]
    | <TEMP n> ->
        gen_move r (Register (Regs.use_temp n))
    | <(LOADW|LOADC), <REGVAR i>> ->
        let rv = List.nth stable i in
        reserve_reg rv; gen_move r (Register rv)
    | <LOADW, t1> -> 
        let v1 = e_addr t1 in
        gen_reg "ldr" [r; v1]
    | <LOADC, t1> -> 
        let v1 = e_addr t1 in
        gen_reg "ldrb" [r; v1]

    | <MONOP Uminus, t1> -> unary "neg" t1
    | <MONOP Not, t1> -> 
        let v1 = e_reg t1 anyreg in
        gen_reg "eor" [r; v1; Const 1]
    | <MONOP BitNot, t1> -> unary "mvn" t1

    | <OFFSET, t1, <CONST n>> when fits_add n ->
        (* Allow add for negative constants *)
        let v1 = e_reg t1 anyreg in
        gen_reg "add" [r; v1; Const n]
    | <OFFSET, t1, t2> -> binary "add" t1 t2

    | <BINOP Plus, t1, t2> -> binary "add" t1 t2
    | <BINOP Minus, t1, t2> -> binary "sub" t1 t2
    | <BINOP And, t1, t2> -> binary "and" t1 t2
    | <BINOP Or, t1, t2> -> binary "orr" t1 t2
    | <BINOP Lsl, t1, t2> -> binary "lsl" t1 t2
    | <BINOP Lsr, t1, t2> -> binary "lsr" t1 t2
    | <BINOP Asr, t1, t2> -> binary "asr" t1 t2
    | <BINOP BitAnd, t1, t2> -> binary "and" t1 t2
    | <BINOP BitOr, t1, t2> -> binary "orr" t1 t2

    | <BINOP Times, t1, <CONST 3>> ->
        let v1 = e_reg t1 anyreg in
        reserve_reg (reg_of v1);
        gen_reg "add" [r; v1; Shift (reg_of v1, 1)]
    | <BINOP Times, t1, <CONST 5>> ->
        let v1 = e_reg t1 anyreg in
        reserve_reg (reg_of v1);
        gen_reg "add" [r; v1; Shift (reg_of v1, 2)]
    | <BINOP Times, t1, <CONST 6>> ->
        let v1 = e_reg t1 anyreg in
        reserve_reg (reg_of v1);
        let v2 = gen_reg "lsl" [r; v1; Const 1] in
        gen_reg "add" [r; v2; Shift (reg_of v1, 2)]
    | <BINOP Times, t1, <CONST 7>> ->
        let v1 = e_reg t1 anyreg in
        reserve_reg (reg_of v1);
        gen_reg "rsb" [r; v1; Shift (reg_of v1, 3)]
    | <BINOP Times, t1, <CONST 9>> ->
        let v1 = e_reg t1 anyreg in
        reserve_reg (reg_of v1);
        gen_reg "add" [r; v1; Shift (reg_of v1, 3)]
    | <BINOP Times, t1, <CONST 10>> ->
        let v1 = e_reg t1 anyreg in
        reserve_reg (reg_of v1);
        let v2 = gen_reg "lsl" [r; v1; Const 1] in
        gen_reg "add" [r; v2; Shift (reg_of v1, 3)]
    | <BINOP Times, t1, <CONST 36>> ->
        let v1 = e_reg t1 anyreg in
        reserve_reg (reg_of v1);
        let v2 = gen_reg "lsl" [r; v1; Const 2] in
        gen_reg "add" [r; v2; Shift (reg_of v1, 5)]
 
    | <BINOP Times, t1, t2> ->
        (* The mul instruction needs both operands in registers *)
        let v1 = e_reg t1 anyreg in
        let v2 = e_reg t2 anyreg in
        gen_reg "mul" [r; v1; v2]

    | <BINOP Eq, t1, t2> -> compare "moveq" t1 t2
    | <BINOP Neq, t1, t2> -> compare "movne" t1 t2
    | <BINOP Gt, t1, t2> -> compare "movgt" t1 t2
    | <BINOP Geq, t1, t2> -> compare "movge" t1 t2
    | <BINOP Lt, t1, t2> -> compare "movlt" t1 t2
    | <BINOP Leq, t1, t2> -> compare "movle" t1 t2

    | <BOUND, t1, t2> ->
        let v1 = e_reg t1 r in
        let v2 = e_rand t2 in
        release v2;
        emit "cmp" [v1; v2];
        emit "seths" [Register (R 0); Const !line];
        emit "blhs" [Global "check"];
        v1

    | <NCHECK, t1> ->
        let v1 = e_reg t1 r in
        emit "cmp" [v1; Const 0];
        emit "seteq" [Register (R 0); Const !line];
        emit "bleq" [Global "nullcheck"];
        v1

    | <w, @args> ->
        failwith (sprintf "eval $" [fInst w])

(* |e_rand| -- evaluate to form second operand *)
and e_rand =
  (* returns |Const| or |Register| *)
  function
      <CONST n> when fits_immed n ->
        Const n
    | <BINOP Lsl, t1, <CONST n>> when n < 32 ->
        let v1 = e_reg t1 anyreg in
        Shift (reg_of v1, n)
    | t ->
        e_reg t anyreg

(* |e_addr| -- evaluate to form an address for ldr or str *)
and e_addr =
  (* returns |Index| *)
  function
      <LOCAL n> when fits_offset n ->
        Index (R_fp, n) 
    | <OFFSET, t1, <CONST n>> when fits_offset n ->
        let v1 = e_reg t1 anyreg in
        Index (reg_of v1, n)
    | <OFFSET, t1, <BINOP Lsl, t2, <CONST n>>> when n < 32 ->
        let v1 = e_reg t1 anyreg
        and v2 = e_reg t2 anyreg in
        Index2 (reg_of v1, reg_of v2, n)
    | <OFFSET, t1, t2> ->
        let v1 = e_reg t1 anyreg
        and v2 = e_reg t2 anyreg in
        Index2 (reg_of v1, reg_of v2, 0)
    | t ->
        let v1 = e_reg t anyreg in
        Index (reg_of v1, 0)

(* |e_call| -- execute procedure call *)
let e_call =
  function
      <GLOBAL f> -> 
        gen "bl" [Global f]
    | t -> 
        let v1 = e_reg t anyreg in
        gen "blx" [v1]

(* |e_stmt| -- generate code to execute a statement *)
let e_stmt t =

  (* Conditional jump *)
  let condj op lab t1 t2 =
    let v1 = e_reg t1 anyreg in
    let v2 = e_rand t2 in
    gen "cmp" [v1; v2];
    gen op [Label lab] in

  (* Procedure call *)
  let call t =
    spill_temps volatile;     (* Spill any remaining temps *)
    e_call t;                 (* Call the function *)
    List.iter (function r ->  (* Release argument registers *)
      if not (is_free r) then release_reg r) volatile in

  match t with
      <CALL k, t1> -> 
        call t1

    | <DEFTEMP n, <CALL k, t1>> ->
        call t1;
        reserve_reg (R 0); 
        Regs.def_temp n (R 0)

    | <DEFTEMP n, t1> ->
        let v1 = e_reg t1 anytemp in
        Regs.def_temp n (reg_of v1)

    | <(STOREW|STOREC), t1, <REGVAR i>> ->
        let rv = List.nth stable i in
        release (e_reg t1 (Register rv))
    | <STOREW, t1, t2> -> 
        let v1 = e_reg t1 anyreg in
        let v2 = e_addr t2 in
        gen "str" [v1; v2]
    | <STOREC, t1, t2> -> 
        let v1 = e_reg t1 anyreg in
        let v2 = e_addr t2 in
        gen "strb" [v1; v2]

    | <RESULTW, t1> ->
        release (e_reg t1 (Register (R 0)))

    | <LABEL lab> -> emit_lab lab

    | <JUMP lab> -> gen "b" [Label lab]

    | <JUMPC (Eq, lab), t1, t2> -> condj "beq" lab t1 t2
    | <JUMPC (Lt, lab), t1, t2> -> condj "blt" lab t1 t2
    | <JUMPC (Gt, lab), t1, t2> -> condj "bgt" lab t1 t2
    | <JUMPC (Leq, lab), t1, t2> -> condj "ble" lab t1 t2
    | <JUMPC (Geq, lab), t1, t2> -> condj "bge" lab t1 t2
    | <JUMPC (Neq, lab), t1, t2> -> condj "bne" lab t1 t2

    | <JCASE (table, deflab), t1> ->
        (* This jump table code exploits the fact that on ARM, reading
           the pc gives a value 8 bytes beyond the current instruction,
           so in the ldrlo instruction below, pc points to the branch
           table itself. *)
        let v1 = e_reg t1 anyreg in
        emit "cmp" [v1; Const (List.length table)];
        gen "ldrlo" [Register R_pc; Index2 (R_pc, reg_of v1, 2)];
        gen "b" [Label deflab];
        List.iter (fun lab -> emit ".word" [Label lab]) table

    | <ARG i, <TEMP k>> when i < 4 ->
        (* Avoid annoying spill and reload if the value is a temp
           already in the correct register: e.g. in f(g(x)). *)
        let r = R i in
        let r1 = Regs.use_temp k in
        spill_temps [r];
        ignore (gen_move (Register r) (Register r1))
    | <ARG i, t1> when i < 4 ->
        let r = R i in
        spill_temps [r];
        ignore (e_reg t1 (Register r))
    | <ARG i, t1> when i >= 4 ->
        need_stack (4*i-12);
        let v1 = e_reg t1 anyreg in
        gen "str" [v1; Index (R_sp, 4*i-16)]

    | <STATLINK, t1> ->
        let r = R 10 in
        spill_temps [r];
        ignore (e_reg t1 (Register r))

    | <w, @ts> -> 
        failwith (sprintf "e_stmt $" [fInst w])

(* |process| -- generate code for a statement, or note a line number *)
let process =
  function
      <LINE n> ->
        if !line <> n then
          emit_comment (Source.get_line n);
        line := n
    | t ->
        if !debug > 0 then emit_tree t;
        e_stmt t;
        if !debug > 1 then emit_comment (Regs.dump_regs ())

(* |translate| -- translate a procedure body *)
let translate lab nargs fsize nregv code =
  Target.start_proc lab nargs fsize;
  Regs.get_regvars nregv;
  (try List.iter process code with exc -> 
    (* Code generation failed, but let's see how far we got *)
    Target.flush_proc (); raise exc);
  Target.end_proc ()
