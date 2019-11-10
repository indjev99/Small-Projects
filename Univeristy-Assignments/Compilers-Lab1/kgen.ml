(* lab1/kgen.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Tree
open Keiko

let optflag = ref false

(* |gen_expr| -- generate code for an expression *)
let rec gen_expr =
  function
      Constant x ->
        CONST x
    | Variable x ->
        SEQ [LINE x.x_line; LDGW x.x_lab]
    | Monop (w, e1) ->
        SEQ [gen_expr e1; MONOP w]
    | Binop (w, e1, e2) ->
        SEQ [gen_expr e1; gen_expr e2; BINOP w]
    | IfExpr (test, thenexp, elsexp) ->
        let thenlab = label () and elselab = label () in
        SEQ [gen_cond test thenlab elselab;
          LABEL thenlab; gen_expr thenexp;
          LABEL elselab; gen_expr elsexp]

(* |gen_cond| -- generate code for short-circuit condition *)
and gen_cond e tlab flab =
  (* Jump to |tlab| if |e| is true and |flab| if it is false *)
  match e with
      Constant x ->
        if x <> 0 then JUMP tlab else JUMP flab
    | Binop ((Eq|Neq|Lt|Gt|Leq|Geq) as w, e1, e2) ->
        SEQ [gen_expr e1; gen_expr e2; JUMPC (w, tlab); JUMP flab]
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
        
(* |gen_multipop| -- generates code to POP n times *)
let rec gen_multipop n = SEQ (gen_multipop_util n)

and gen_multipop_util n =
  match n with
      0 -> []
    | n -> POP :: gen_multipop_util (n - 1)

(* |gen_matchlist_cond| -- generate trying to match the top thing on the stack to a list of ints *)
let rec gen_matchlist_cond vals tlab flab =
  (* Jump to |tlab| if there is a match and |flab| if there isn't *)
  match vals with
      [] -> JUMP flab
    | x :: xs ->
        SEQ [DUP; CONST x; JUMPC (Eq, tlab); gen_matchlist_cond xs tlab flab]

(* |gen_case_match| -- generate code for a case match *)
let rec gen_casematch exitlab depth endlab case =
  match case with
      None -> NOP
    | Default (body) ->
        gen_stmt exitlab depth body
    | Match (vals, body, tail) ->
        let matchlab = label () and nextlab = label () in
        SEQ [gen_matchlist_cond vals matchlab nextlab; LABEL matchlab;
          gen_stmt exitlab depth body; JUMP endlab; LABEL nextlab;
          gen_casematch exitlab depth endlab tail]

(* |gen_stmt| -- generate code for a statement *)
and gen_stmt exitlab depth s =
  match s with
      Skip -> NOP
    | Seq stmts -> SEQ (List.map (gen_stmt exitlab depth) stmts )
    | Assign (v, e) ->
        SEQ [LINE v.x_line; gen_expr e; STGW v.x_lab]
    | Print e ->
        SEQ [gen_expr e; CONST 0; GLOBAL "lib.print"; PCALL 1]
    | Newline ->
        SEQ [CONST 0; GLOBAL "lib.newline"; PCALL 0]
    | IfStmt (test, thenpt, elsept) ->
        let thenlab = label () and elselab = label () and endlab = label () in
        SEQ [gen_cond test thenlab elselab; 
          LABEL thenlab; gen_stmt exitlab depth thenpt; JUMP endlab;
          LABEL elselab; gen_stmt exitlab depth elsept; LABEL endlab]
    | CaseStmt (exp, tail) ->
        let endlab = label () in
        SEQ [gen_expr exp; gen_casematch exitlab (depth + 1) endlab tail; LABEL endlab; POP]
    | LoopStmt (body) ->
        let looplab = label () and endlab = label () in
        SEQ [LABEL looplab; gen_stmt endlab depth body;
          JUMP looplab; LABEL endlab]
    | WhileStmt (test, thenbody, elsebody) ->
        let whilelab = label() and thenlab = label () and elselab = label () and endlab = label () in
        SEQ [LABEL whilelab; gen_cond test thenlab elselab;
          LABEL thenlab; gen_stmt endlab 0 thenbody; JUMP whilelab;
          LABEL elselab; gen_stmt endlab 0 elsebody; JUMP whilelab;
          LABEL endlab]
    | RepeatStmt (body, test) ->
        let repeatlab = label () and endlab = label () in
        SEQ [LABEL repeatlab; gen_stmt endlab 0 body;
          gen_cond test endlab repeatlab; LABEL endlab]
    | ExitStmt ->
        SEQ[gen_multipop depth; JUMP exitlab]

(* |translate| -- generate code for the whole program *)
let translate (Program ss) =
  let exitlab = label () in
  let code = SEQ [gen_stmt exitlab 0 ss; LABEL exitlab] in
  Keiko.output (if !optflag then Peepopt.optimise code else code)
