(* lab4/optree.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* |op| -- type of picoPascal operators *)
type op = Plus | Minus | Times | Div | Mod | Eq 
  | Uminus | Lt | Gt | Leq | Geq | Neq 
  | And | Or | Not | Lsl | Lsr | Asr | BitAnd | BitOr | BitNot

val fOp : op -> Print.arg

(* |symbol| -- global symbols *)
type symbol = string

val nosym : symbol

val gensym : unit -> symbol

(* |codelab| -- type of code labels *)
type codelab

val nolab : codelab

(* |label| -- generate a code label *)
val label : unit -> codelab

val fLab : codelab -> Print.arg

(* |inst| -- type of intermediate instructions *)
type inst =
    CONST of int                (* Constant (value) *)
  | GLOBAL of symbol            (* Global address (symbol) *)
  | LOCAL of int                (* Local address (offset) *)
  | REGVAR of int               (* Register (index) *)
  | LOADC                       (* Load char *)
  | LOADW                       (* Load word *)
  | STOREC                      (* Store char *)
  | STOREW                      (* Store word *)
  | ARG of int                  (* Pass argument (index) *)
  | STATLINK                    (* Pass static link *)
  | CALL of int                 (* Call procedure (nparams) *)
  | RESULTW                     (* Procedure result *)
  | MONOP of op                 (* Perform unary operation (op) *)
  | BINOP of op                 (* Perform binary operation (op) *)
  | OFFSET                      (* Add address and offset *)
  | BOUND                       (* Array bound check *)
  | NCHECK                      (* Null pointer check *)
  | LABEL of codelab            (* Set code label *)
  | JUMP of codelab             (* Unconditional branch (dest) *)
  | JUMPC of op * codelab       (* Conditional branch (cond, dest) *)
  | JCASE of codelab list * codelab (* Jump table *)

  (* Extra instructions *)
  | LINE of int                 (* Line number *)
  | NOP
  | SEQ
  | AFTER                       (* Expression with side effect *)
  | DEFTEMP of int              (* Define temp *)
  | TEMP of int                 (* Temporary *)

(* |Inst| -- printf format for instructions *)
val fInst : inst -> Print.arg

(* |do_monop| -- evaluate unary operation *)
val do_monop : op -> int -> int

(* |do_binop| -- evaluate binary operation *)
val do_binop : op -> int -> int -> int

(* |negate| -- find opposite for comparison op *)
val negate : op -> op

(* Operator trees *)

(* |optree| -- type of operator trees *)
type optree = Node of inst * optree list

(* |canon| -- eliminate SEQ, NOP, AFTER nodes *)
val canon : optree -> optree list

(* |flatten| -- move args before calls *)
val flatten : optree list -> optree list

(* |print_optree| -- output operator tree on stdout with line breaking *)
val print_optree : string -> optree -> unit
