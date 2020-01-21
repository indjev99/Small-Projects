(* lab4/tran.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* The function |translate| takes the body of a procedure (represented
   as a list of optrees) and generates machine code as a sequence of calls
   to the interface provided by the Target module. *)

(* |translate| -- generate code for a procedure body *)
val translate : 
  Optree.symbol -> int -> int -> int -> Optree.optree list -> unit

val debug : int ref
