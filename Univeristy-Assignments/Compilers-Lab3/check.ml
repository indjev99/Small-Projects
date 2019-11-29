(* lab3/check.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Tree 
open Dict 
open Print 

(* |err_line| -- line number for error messages *)
let err_line = ref 1

(* |Semantic_error| -- exception raised if error detected *)
exception Semantic_error of string * Print.arg list * int

(* |sem_error| -- issue error message by raising exception *)
let sem_error fmt args = 
  raise (Semantic_error (fmt, args, !err_line))

(* |accum| -- fold_left with arguments swapped *)
let rec accum f xs a =
  match xs with
      [] -> a
    | y::ys -> accum f ys (f y a)

(* |lookup_def| -- find definition of a name, give error is none *)
let lookup_def x env =
  err_line := x.x_line;
  try let d = lookup x.x_name env in x.x_def <- Some d; d with 
    Not_found -> sem_error "$ is not declared" [fStr x.x_name]

(* |add_def| -- add definition to env, give error if already declared *)
let add_def d env =
  try define d env with 
    Exit -> sem_error "$ is already declared" [fStr d.d_tag]

(* |check_expr| -- check and annotate an expression *)
let rec check_expr e env =
  match e with
      Constant n -> ()
    | Variable x -> 
        let d = lookup_def x env in
        begin
          match d.d_kind with
              VarDef -> ()
            | ProcDef _ -> ()
        end
    | Monop (w, e1) -> 
        check_expr e1 env
    | Binop (w, e1, e2) -> 
        check_expr e1 env;
        check_expr e2 env
    | Call (p, args) ->
        let d = lookup_def p env in
        begin
          match d.d_kind with
              VarDef -> ()
            | ProcDef nargs ->
                if List.length args <> nargs then
                  sem_error "procedure $ needs $ arguments" 
                    [fStr p.x_name; fNum nargs];
        end;
        List.iter (fun e1 -> check_expr e1 env) args

(* |check_stmt| -- check and annotate a statement *)
let rec check_stmt s inproc env =
  match s with
      Skip -> ()
    | Seq ss ->
        List.iter (fun s1 -> check_stmt s1 inproc env) ss
    | Assign (x, e) ->
        let d = lookup_def x env in
        begin
          match d.d_kind with
              VarDef -> check_expr e env
            | ProcDef _ -> 
                sem_error "$ is not a variable" [fStr x.x_name]
        end
    | Return e ->
        if not inproc then
          sem_error "return statement only allowed in procedure" [];
        check_expr e env
    | IfStmt (test, thenpt, elsept) ->
        check_expr test env;
        check_stmt thenpt inproc env;
        check_stmt elsept inproc env
    | WhileStmt (test, body) ->
        check_expr test env;
        check_stmt body inproc env
    | Print e ->
        check_expr e env
    | Newline ->
        ()

(* |serialize| -- number a list, starting from 0 *)
let serialize xs = 
  let rec count i =
    function
        [] -> []
      | x :: xs -> (i, x) :: count (i+1) xs in
  count 0 xs

(*
Frame layout

        arg n
        ...
fp+16:  arg 1
fp+12:  static link
fp+8:   current cp
fp+4:   return addr
fp:     dynamic link
fp-4:   local 1
        ...
        local m
*)

let arg_base = 16
let loc_base = 0

(* |declare_local| -- declare a formal parameter or local *)
let declare_local x lev off env =
  let d = { d_tag = x; d_kind = VarDef; d_level = lev; 
                d_lab = ""; d_off = off } in
  add_def d env

(* |declare_global| -- declare a global variable *)
let declare_global x env =
  let d = { d_tag = x; d_kind = VarDef; d_level = 0; 
                d_lab = sprintf "_$" [fStr x]; d_off = 0 } in
  add_def d env

(* |declare_proc| -- declare a procedure *)
let declare_proc (Proc (p, formals, body)) lev env =
  let lab = sprintf "$_$" [fStr p.x_name; fNum (label ())] in
  let d = { d_tag = p.x_name; 
                d_kind = ProcDef (List.length formals); d_level = lev;
                d_lab = lab; d_off = 0 } in
  p.x_def <- Some d; add_def d env

(* |check_proc| -- check a procedure body *)
let rec check_proc (Proc (p, formals, Block (vars, procs, body))) lev env =
  err_line := p.x_line;
  let env' =
    accum (fun (i, x) -> declare_local x lev (arg_base + 4*i))
      (serialize formals) (new_block env) in
  let env'' = 
    accum (fun (i, x) -> declare_local x lev (loc_base - 4*(i+1)))
      (serialize vars) env' in
  let env''' = 
    accum (fun d -> declare_proc d (lev+1)) procs env'' in
  List.iter (fun d -> check_proc d (lev+1) env''') procs;
  check_stmt body true env'''

(* |annotate| -- check and annotate a program *)
let annotate (Program (Block (vars, procs, body))) =
  let env = accum declare_global vars empty in
  let env' = accum (fun d -> declare_proc d 1) procs env in
  List.iter (fun d -> check_proc d 1 env') procs;
  check_stmt body false env'
