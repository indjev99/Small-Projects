(* lab3/check.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

open Tree

(* |annotate| -- check tree for type errors and annotate with definitions *)
val annotate : program -> unit

(* |Semantic_error| -- exception raised if error detected *)
exception Semantic_error of string * Print.arg list * int
