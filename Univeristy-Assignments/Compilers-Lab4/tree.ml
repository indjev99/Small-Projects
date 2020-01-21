(* lab4/tree.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Dict
open Print

(* |name| -- type for applied occurrences, with mutable annotations *)
type name = 
  { x_name: ident;              (* Name of the reference *)
    x_line: int;                (* Line number *)
    mutable x_def: def option } (* Definition in scope *)

(* abstract syntax *)
type program = Prog of block * def list ref

and block = Block of decl list * stmt * int ref * int ref

and decl = 
    ConstDecl of ident * expr
  | VarDecl of def_kind * ident list * typexpr
  | TypeDecl of (ident * typexpr) list
  | ProcDecl of proc_heading * block
  | PParamDecl of proc_heading

and proc_heading = Heading of name * decl list * typexpr option 

and stmt = 
  { s_guts: stmt_guts;
    s_line: int }

and stmt_guts =
    Skip 
  | Seq of stmt list
  | Assign of expr * expr
  | ProcCall of name * expr list 
  | Return of expr option
  | IfStmt of expr * stmt * stmt
  | WhileStmt of expr * stmt
  | RepeatStmt of stmt * expr
  | ForStmt of expr * expr * expr * stmt * def option ref
  | CaseStmt of expr * (expr * stmt) list * stmt

and expr = 
  { e_guts: expr_guts; 
    mutable e_type: ptype; 
    mutable e_value: int option }

and expr_guts =
    Constant of int * ptype
  | Variable of name
  | Sub of expr * expr 
  | Select of expr * name
  | Deref of expr
  | String of Optree.symbol * int
  | Nil
  | FuncCall of name * expr list
  | Monop of Optree.op * expr 
  | Binop of Optree.op * expr * expr

and typexpr = 
    TypeName of name 
  | Array of expr * typexpr
  | Record of decl list
  | Pointer of typexpr

(* |makeExpr| -- construct an expression node with dummy annotations *)
let makeExpr e = 
  { e_guts = e; e_type = voidtype; e_value = None }

(* |makeStmt| -- construct a stmt node *)
let makeStmt (s, n) = { s_guts = s; s_line = n }

(* |makeName| -- contruct a name node with dummy annotations *)
let makeName (x, n) = { x_name = x; x_line = n; x_def = None }

let seq =
  function
      [] -> makeStmt (Skip, 0)  (* Use Skip in place of Seq [] *)
    | [s] -> s                  (* Don't use a Seq node for one element *)
    | ss -> makeStmt (Seq ss, 0)

let get_def x =
  match x.x_def with 
      Some d -> d 
    | None -> failwith (sprintf "missing def of $" [fId x.x_name])

(* |MakeBlock| -- construct a block node with dummy annotations *)
let makeBlock (decls, stmts) = Block (decls, stmts, ref 0, ref 0)


(* Grinder *)

let fTail f xs = 
  let g prf = List.iter (fun x -> prf " $" [f x]) xs in fExt g

let fList f =
  function
      [] -> fStr "()"
    | x::xs -> fMeta "($$)" [f x; fTail(f) xs]

let fName x = fId x.x_name

let rec fBlock (Block (decls, stmts, _, _)) =
  match decls with
      [] -> fMeta "(BLOCK $)" [fStmt stmts]
    | _ -> fMeta "(BLOCK (DECLS$) $)" [fTail(fDecl) decls; fStmt stmts]

and fDecl = 
  function
      ConstDecl (x, e) -> 
        fMeta "(CONST $ $)" [fId x; fExpr e]
    | VarDecl (kind, xs, te) -> 
        fMeta "($ $ $)" [fKind kind; fList(fId) xs; fType te]
    | TypeDecl tds ->
        let f (x, te) = fMeta "($ $)" [fId x; fType te] in
        fMeta "(TYPE$)" [fTail(f) tds]
    | ProcDecl (heading, body) ->
        fMeta "(PROC $ $)" [fHeading heading; fBlock body]
    | PParamDecl heading ->
        fMeta "(PROC $)" [fHeading heading]

and fKind =
  function
      VarDef -> fStr "VAR"
    | CParamDef -> fStr "PARAM"
    | VParamDef -> fStr "VPARAM"
    | FieldDef -> fStr "FIELD"
    | _ -> fStr "???"

and fHeading (Heading (p, fps, te)) =
  let res = match te with Some t -> fType t | None -> fStr "VOID" in
  fMeta "($ $ $)" [fName p; fList(fDecl) fps; res]

and fStmt s = 
  match s.s_guts with
      Skip -> fStr "(SKIP)"
    | Seq stmts -> fMeta "(SEQ$)" [fTail(fStmt) stmts]
    | Assign (e1, e2) -> fMeta "(ASSIGN $ $)" [fExpr e1; fExpr e2]
    | ProcCall (p, aps) -> fMeta "(CALL $$)" [fName p; fTail(fExpr) aps]
    | Return (Some e) -> fMeta "(RETURN $)" [fExpr e]
    | Return None -> fStr "(RETURN)"
    | IfStmt (test, thenpt, elsept) -> 
        fMeta "(IF $ $ $)" [fExpr test; fStmt thenpt; fStmt elsept]
    | WhileStmt (test, body) ->
        fMeta "(WHILE $ $)" [fExpr test; fStmt body]
    | RepeatStmt (body, test) ->
        fMeta "(REPEAT $ $)" [fStmt body; fExpr test]
    | ForStmt (var, lo, hi, body, _) ->
        fMeta "(FOR $ $ $ $)" [fExpr var; fExpr lo; fExpr hi; fStmt body]
    | CaseStmt (sel, arms, deflt) ->
        let fArm (lab, body) = fMeta "($ $)" [fExpr lab; fStmt body] in
        fMeta "(CASE $ $ $)" [fExpr sel; fList(fArm) arms; fStmt deflt]

and fExpr e =
  match e.e_guts with
      Constant (n, t) -> fMeta "(CONST $)" [fNum n]
    | Variable x -> fName x
    | Sub (e1, e2) -> fMeta "(SUB $ $)" [fExpr e1; fExpr e2]
    | Select (e1, x) -> fMeta "(SELECT $ $)" [fExpr e1; fName x]
    | Deref e1 -> fMeta "(DEREF $)" [fExpr e1]
    | String (s, _) -> fMeta "(STRING $)" [fStr s]
    | Nil -> fStr "(NIL)"
    | FuncCall (p, aps) ->
        fMeta "(CALL $$)" [fName p; fTail(fExpr) aps]
    | Monop (w, e1) -> 
        fMeta "($ $)" [Optree.fOp w; fExpr e1]
    | Binop (w, e1, e2) -> 
        fMeta "($ $ $)" [Optree.fOp w; fExpr e1; fExpr e2]

and fType =
  function
      TypeName x -> fName x
    | Array (e, t1) -> fMeta "(ARRAY $ $)" [fExpr e; fType t1]
    | Record fields -> fMeta "(RECORD$)" [fTail(fDecl) fields]
    | Pointer t1 -> fMeta "(POINTER $)" [fType t1]

let print_tree fp pfx (Prog (body, _)) = 
  fgrindf fp pfx "(PROGRAM $)" [fBlock body]
