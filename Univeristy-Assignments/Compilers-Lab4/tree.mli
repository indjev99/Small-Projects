(* lab4/tree.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

open Dict

(*
This module describes the type of abstract syntax trees that is used
as the main interface between parts of the comipler.  A tree is built
by the parser, then checked by the semantic analyser, which annotates
identifiers in the tree with their definitions.  The intermediate code
generator finally traverses the tree, emitting code for each
expression or statement.

This module also contains some functions that are used to build the
tree initially; they construct nodes with default values for the
annotations.  Proper values are filled in later during semantic
analysis.
*)

(* |name| -- type for applied occurrences, with mutable annotations *)
type name = 
  { x_name: ident;              (* Name of the reference *)
    x_line: int;                (* Line number *)
    mutable x_def: def option } (* Definition in scope *)

val get_def : name -> def

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

(* seq -- neatly join a list of statements into a sequence *)
val seq : stmt list -> stmt

(* |makeExpr| -- construct an expr node with dummy annotations *)
val makeExpr : expr_guts -> expr

(* |makeStmt| -- construct a stmt node *)
val makeStmt : stmt_guts * int -> stmt

(* |makeName| -- construct a name node with dummy annotations *)
val makeName : ident * int -> name

(* |makeBlock| -- construct a block node with dummy annotations *)
val makeBlock : decl list * stmt -> block

(* |print_tree| -- pretty-print a tree *)
val print_tree : out_channel -> string -> program -> unit
