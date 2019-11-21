(* lab2/tree.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

open Dict

(*
This module describes the type of abstract syntax trees that is used
as the main interface between parts of the comipler.  A tree is built
by the parser, then checked by the semantic analyser, which annotates
identifiers in the tree with their definitions.  The intermediate code
generator finally traverses the tree, emitting code for each
expression or statement.

The module also contains some functions that are used to build the
tree initially; they construct nodes with default values for the
annotations.  Proper values are filled in later during semantic
analysis.
*)

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


(* seq -- neatly join a list of statements into a sequence *)
val seq : stmt list -> stmt

(* |makeName| -- construct a name node with dummy annotations *)
val makeName : ident -> int -> name

(* |get_def| -- rerieve definition from name *)
val get_def : name -> def

(* |makeExpr| -- construct an expr node with dummy annotations *)
val makeExpr : expr_guts -> expr

(* |print_tree| -- pretty-print a tree *)
val print_tree : out_channel -> program -> unit
