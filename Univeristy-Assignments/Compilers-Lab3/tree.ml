(* lab3/tree.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Dict
open Print

(* |name| -- type for applied occurrences with annotations *)
type name = 
  { x_name: ident;              (* Name of the reference *)
    x_line: int;                (* Line number *)
    mutable x_def: def option } (* Definition in scope *)

type expr = 
    Constant of int
  | Variable of name
  | Monop of Keiko.op * expr
  | Binop of Keiko.op * expr * expr
  | Call of name * expr list

type stmt =
    Skip
  | Seq of stmt list
  | Assign of name * expr
  | Return of expr
  | IfStmt of expr * stmt * stmt
  | WhileStmt of expr * stmt
  | Print of expr
  | Newline

type block = Block of ident list * proc list * stmt

and proc = Proc of name * ident list * block

type program = Program of block

let seq =
  function
      [] -> Skip                (* Use Skip in place of Seq [] *)
    | [s] -> s                  (* Don't use a Seq node for one element *)
    | ss -> Seq ss

let makeName x ln = 
  { x_name = x; x_line = ln; x_def = None }

let get_def x =
  match x.x_def with
      Some d -> d
    | None -> failwith (sprintf "missing def on $" [fStr x.x_name])


(* Pretty printer *)

open Print

let fTail f xs =
  let g prf = List.iter (fun x -> prf "; $" [f x]) xs in fExt g

let fList f =
  function
      [] -> fStr "[]"
    | x::xs -> fMeta "[$$]" [f x; fTail(f) xs]

let fName x = fStr x.x_name

let rec fExpr =
  function
      Constant n ->
        fMeta "Number_$" [fNum n]
    | Variable x -> 
        fMeta "Variable_$" [fName x]
    | Monop (w, e1) -> 
        fMeta "Monop_($, $)" [fStr (Keiko.op_name w); fExpr e1]
    | Binop (w, e1, e2) -> 
        fMeta "Binop_($, $, $)" [fStr (Keiko.op_name w); fExpr e1; fExpr e2]
    | Call (x, es) ->
        fMeta "Call_($, $)" [fName x; fList(fExpr) es]

let rec fStmt = 
  function
      Skip -> 
        fStr "Skip"
    | Seq ss -> 
        fMeta "Seq_$" [fList(fStmt) ss]
    | Assign (x, e) -> 
        fMeta "Assign_($, $)" [fName x; fExpr e]
    | Return e ->
        fMeta "Return_($)" [fExpr e]
    | Print e -> 
        fMeta "Print_($)" [fExpr e]
    | Newline -> 
        fStr "Newline"
    | IfStmt (e, s1, s2) ->
        fMeta "IfStmt_($, $, $)" [fExpr e; fStmt s1; fStmt s2]
    | WhileStmt (e, s) -> 
        fMeta "WhileStmt_($, $)" [fExpr e; fStmt s]

let rec fBlock (Block (vs, ps, body)) =
  fMeta "Block_($, $, $)" [fList(fStr) vs; fList(fProc) ps; fStmt body]

and fProc (Proc (x, fps, body)) =
  fMeta "Proc_($, $, $)" [fName x; fList(fStr) fps; fBlock body]

let print_tree fp (Program b) =
  fgrindf fp "" "Program_($)" [fBlock b]
