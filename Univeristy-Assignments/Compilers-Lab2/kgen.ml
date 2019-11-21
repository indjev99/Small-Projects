(* lab2/kgen.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Dict 
open Tree 
open Keiko 
open Print

let optflag = ref false

(* |line_number| -- find line number of variable reference *)
let rec line_number e =
  match e.e_guts with
      Variable x -> x.x_line
    | Sub (a, e) -> line_number a
    | _ -> 999

(* |load_var| -- loads a variable with size *)
let load_var =
  function
      1 -> LOADC
    | 4 -> LOADW
    | _ -> failwith "load_var"

(* |store_var| -- stores a variable with size *)
let store_var =
  function
      1 -> STOREC
    | 4 -> STOREW
    | _ -> failwith "store_var"

(* |gen_expr| -- generate code for an expression *)
let rec gen_expr e =
  match e.e_guts with
      Variable _ | Sub _ ->
        let code, _ = gen_addr e
        and sz = type_size (root_type e.e_type) in
        SEQ [code; load_var sz]
    | Constant (n, t) ->
        CONST n
    | Monop (w, e1) ->
        SEQ [gen_expr e1; MONOP w]
    | Binop (w, e1, e2) ->
        SEQ [gen_expr e1; gen_expr e2; BINOP w]

(* |gen_addr| -- generate code to push address of a variable *)
and gen_addr v =
  match v.e_guts with
      Variable x ->
        let d = get_def x in
        (SEQ [LINE x.x_line; GLOBAL d.d_lab], x.x_line)
    | Sub (xs, idx) ->
        let base_addr_code, line = gen_addr xs in
        let sz = type_size (base_type xs.e_type) in
        let sz_mul_code = if sz == 1 then NOP else SEQ [CONST sz; BINOP Times] in
        let idx_expr_code = gen_expr idx in
        let array_len = array_length xs.e_type in
        let idx_addr_code = match idx_expr_code with
            CONST n -> if n >= 0 && n < array_len then CONST (n * sz)
                       else failwith "gen_addr: const array index out of bounds"
          | _ -> SEQ [idx_expr_code; CONST array_len; BOUND line; sz_mul_code] in
        (SEQ [idx_addr_code; base_addr_code; BINOP Plus], line)
    | _ -> failwith "gen_addr"

(* |gen_cond| -- generate code for short-circuit condition *)
let rec gen_cond e tlab flab =
  (* Jump to |tlab| if |e| is true and |flab| if it is false *)
  match e.e_guts with
      Constant (x, t) ->
        if x <> 0 then JUMP tlab else JUMP flab
    | Binop ((Eq|Neq|Lt|Gt|Leq|Geq) as w, e1, e2) ->
        SEQ [gen_expr e1; gen_expr e2;
          JUMPC (w, tlab); JUMP flab]
    | Monop (Not, e1) ->
        gen_cond e1 flab tlab
    | Binop (And, e1, e2) ->
        let lab1 = label () in
        SEQ [gen_cond e1 lab1 flab; LABEL lab1; gen_cond e2 tlab flab]
    | Binop (Or, e1, e2) ->
        let lab1 = label () in
        SEQ [gen_cond e1 tlab lab1; LABEL lab1; gen_cond e2 tlab flab]
    | _ ->
        SEQ [gen_expr e; CONST 0; JUMPC (Neq, tlab); JUMP flab]

(* |gen_stmt| -- generate code for a statement *)
let rec gen_stmt =
  function
      Skip -> NOP
    | Seq stmts -> SEQ (List.map gen_stmt stmts)
    | Assign (v, e) ->
        let code, _ = gen_addr v
        and sz = type_size (root_type v.e_type) in
        SEQ [LINE (line_number v); gen_expr e; code; store_var sz]
    | Print e ->
        SEQ [gen_expr e; CONST 0; GLOBAL "lib.print"; PCALL 1]
    | Newline ->
        SEQ [CONST 0; GLOBAL "lib.newline"; PCALL 0]
    | IfStmt (test, thenpt, elsept) ->
        let lab1 = label () and lab2 = label () and lab3 = label () in
        SEQ [gen_cond test lab1 lab2; 
          LABEL lab1; gen_stmt thenpt; JUMP lab3;
          LABEL lab2; gen_stmt elsept; LABEL lab3]
    | WhileStmt (test, body) ->
        let lab1 = label () and lab2 = label () and lab3 = label () in
        SEQ [JUMP lab2; LABEL lab1; gen_stmt body; 
          LABEL lab2; gen_cond test lab1 lab3; LABEL lab3]

let gen_decl (Decl (xs, t)) =
  List.iter (fun x ->
      let d = get_def x in
      let s = type_size t in
      printf "GLOVAR $ $\n" [fStr d.d_lab; fNum s]) xs

(* |translate| -- generate code for the whole program *)
let translate (Program (ds, ss)) = 
  let code = gen_stmt ss in
  printf "PROC MAIN 0 0 0\n" [];
  Keiko.output (if !optflag then Peepopt.optimise code else code);
  printf "RETURN\n" [];
  printf "END\n\n" [];
  List.iter gen_decl ds
