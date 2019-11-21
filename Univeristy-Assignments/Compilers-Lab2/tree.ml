(* lab2/tree.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Dict
open Print

(* |name| -- type for applied occurrences with annotations *)
type name = 
  { x_name: ident;              (* Name of the reference *)
    x_line: int;                (* Line number *)
    mutable x_def: def option } (* Definition in scope *)


(* Abstract syntax *)

type program = Program of decl list * stmt

and decl = Decl of name list * ptype

and stmt = 
    Skip 
  | Seq of stmt list
  | Assign of expr * expr
  | Print of expr
  | Newline
  | IfStmt of expr * stmt * stmt
  | WhileStmt of expr * stmt

and expr = 
  { e_guts: expr_guts;
    mutable e_type: ptype }

and expr_guts =
    Constant of int * ptype
  | Variable of name
  | Sub of expr * expr
  | Monop of Keiko.op * expr 
  | Binop of Keiko.op * expr * expr

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

let makeExpr e =
  { e_guts = e; e_type = Void }


(* Pretty printer *)

open Print

let fTail f xs =
  let g prf = List.iter (fun x -> prf "; $" [f x]) xs in fExt g

let fList f =
  function
      [] -> fStr "[]"
    | x::xs -> fMeta "[$$]" [f x; fTail(f) xs]

let fName x = fMeta "\"$\"" [fStr x.x_name]

let rec fType =
  function
      Integer -> fStr "Integer"
    | Boolean -> fStr "Boolean"
    | Void -> fStr "Void"
    | Array (n, t) -> fMeta "Array_($, $)" [fNum n; fType t]

let fDecl (Decl (xs, t)) =
  fMeta "Decl_($, $)" [fList(fName) xs; fType t]

let rec fExpr e =
  match e.e_guts with
      Constant (n, t) ->
        fMeta "Const_$" [fNum n]
    | Variable x -> 
        fMeta "Variable_$" [fName x]
    | Sub (e1, e2) ->
        fMeta "Sub_($, $)" [fExpr e1; fExpr e2]
    | Monop (w, e1) -> 
        fMeta "Monop_($, $)" [fStr (Keiko.op_name w); fExpr e1]
    | Binop (w, e1, e2) -> 
        fMeta "Binop_($, $, $)" 
          [fStr (Keiko.op_name w); fExpr e1; fExpr e2]

let rec fStmt = 
  function
      Skip -> 
        fStr "Skip"
    | Seq ss -> 
        fMeta "Seq_$" [fList(fStmt) ss]
    | Assign (e1, e2) -> 
        fMeta "Assign_($, $)" [fExpr e1; fExpr e2]
    | Print e -> 
        fMeta "Print_($)" [fExpr e]
    | Newline -> 
        fStr "Newline"
    | IfStmt (e, s1, s2) ->
        fMeta "IfStmt_($, $, $)" [fExpr e; fStmt s1; fStmt s2]
    | WhileStmt (e, s) -> 
        fMeta "WhileStmt_($, $)" [fExpr e; fStmt s]

let fProg (Program (ds, s)) = 
  fMeta "Program_($, $)" [fList(fDecl) ds; fStmt s]

let print_tree fp t = fgrindf fp "" "$" [fProg t]
