(* lab4/target.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

open Optree

(* |reg| -- type of Risc86 registers *)
type reg = R of int | R_fp | R_sp | R_pc | R_ip | R_any | R_temp | R_none

(* |fReg| -- format register for printing *)
val fReg : reg -> Print.arg

(* |volatile| -- list of caller-save registers *)
val volatile : reg list

(* |stable| -- list of callee-save registers *)
val stable : reg list

(* |operand| -- type of operands for assembly instructions *)
type operand =                  (* VALUE        ASM SYNTAX       *)
    Const of int                (* val          #val             *)
  | Register of reg             (* [reg]        reg              *)
  | Index of reg * int          (* [reg]+val    [reg, #val]      *)
  | Index2 of reg * reg * int   (* [r1]+[r2]<<n [r1, r2, LSL #n] *)
  | Shift of reg * int          (* reg<<n       reg, LSL #n      *)
  | Global of symbol            (* lab          lab              *)
  | Label of codelab            (* lab          lab              *)

(* |fRand| -- format operand for printing *)
val fRand : operand -> Print.arg

(* |reg_of| -- extract register (or R_none) from operand *)
val reg_of : operand -> reg

(* |emit| -- emit an assembly language instruction *)
val emit : string -> operand list -> unit

(* |move_reg| -- emit a register-to-register move *)
val move_reg : reg -> reg -> unit

(* |emit_lab| -- place a label *)
val emit_lab : codelab -> unit

(* |emit_comment| -- insert a comment *)
val emit_comment : string -> unit

(* |emit_tree| -- Print an optree as a comment *)
val emit_tree : optree -> unit

(* |need_stack| -- ensure stack space *)
val need_stack : int -> unit

(* |preamble| -- emit first part of assembly language output *)
val preamble : unit -> unit

(* |postamble| -- emit last part of assembly language output *)
val postamble : unit -> unit

(* |start_proc| -- emit beginning of procedure *)
val start_proc : symbol -> int -> int -> unit

(* |end_proc| -- emit end of procedure *)
val end_proc : unit -> unit

(* |flush_proc| -- dump out code after failure *)
val flush_proc : unit -> unit

(* |emit_string| -- emit assembler code for string constant *)
val emit_string : symbol -> string -> unit

(* |emit_global| -- emit assembler code to define global variable *)
val emit_global : symbol -> int -> unit
