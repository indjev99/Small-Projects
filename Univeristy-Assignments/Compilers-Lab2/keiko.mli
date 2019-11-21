(* common/keiko.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* |codelab| -- type of code labels *)
type codelab = int

(* |label| -- allocate a code label *)
val label : unit -> codelab

(* |op| -- type of picoPascal operators *)
type op = Plus | Minus | Times | Div | Mod | Eq 
  | Uminus | Lt | Gt | Leq | Geq | Neq | And | Or | Not

(* op_name -- map an operator to its name *)
val op_name : op -> string

(* |code| -- type of intermediate instructions *)
type code =
    CONST of int                (* Push constant (value) *)
  | GLOBAL of string            (* Push global address (name) *)
  | LOCAL of int                (* Push local adddress (offset) *)
  | LOADW                       (* Load word *)
  | STOREW                      (* Store word *)
  | LOADC                       (* Load character *)
  | STOREC                      (* Store character *)
  | MONOP of op                 (* Perform unary operation (op) *)
  | BINOP of op                 (* Perform binary operation (op) *)
  | OFFSET                      (* Add address and offset *)
  | LABEL of codelab            (* Set code label *)
  | JUMP of codelab             (* Unconditional branch (dest) *)
  | JUMPC of op * codelab       (* Conditional branch (op, dest) *)
  | PCALL of int                (* Call procedure *)
  | PCALLW of int               (* Proc call with result (nargs) *)
  | RETURNW                     (* Return from procedure *)
  | BOUND of int                (* Bounds check *)
  | CASEJUMP of int             (* Case jump (num cases) *)
  | CASEARM of int * codelab    (* Case value and label *)
  | PACK                        (* Pack two values into one *)
  | UNPACK                      (* Unpack one value into two *)
  | DUP
  | POP

  | LDGW of string              (* Load Global Word (name) *)
  | STGW of string              (* Store Global Word (name) *)
  | LDLW of int                 (* Load Local Word (offset) *)
  | STLW of int                 (* Store Local Word (offset) *)
  | LDNW of int                 (* Load word with offset *)
  | STNW of int                 (* Store word with offset *)

  | LINE of int
  | SEQ of code list
  | NOP

(* |fInst| -- format an instruction for |printf| *)
val fInst : code -> Print.arg

(* |canon| -- flatten a code sequence *)
val canon : code -> code

(* |output| -- output a code sequence *)
val output : code -> unit
