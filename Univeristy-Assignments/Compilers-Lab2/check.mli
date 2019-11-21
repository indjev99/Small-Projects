(* lab2/check.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* 
This module is the semantic analysis pass of the compiler.  It
provides a single function |annotate| that takes a program, checks it
for semantic errors, and annotates each applied occurrence of an
identifier with the corresponding definition.  These annotations are
used by the code generation pass to generate code for variable
references.

If a semantic error is detected, |annotate| raises the exception
|Semantic_error|.  Its arguments are a line number and a format and
argument list that can be passed to printf to print the message.
Because there is no way of resuming the analysis, only one error can
be detected per run of the compiler.
*)

(* |annotate| -- check tree for type errors and annotate with definitions *)
val annotate : Tree.program -> unit

(* |Semantic_error| -- exception raised if error detected *)
exception Semantic_error of string * Print.arg list * int
