(* lab4/check.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

open Tree

(* This module is the semantic analysis pass of the compiler.  It
   provides a single function |annotate| that takes a program, checks
   it for semantic errors, and annotates defining and applied
   occurrences identifiers with the corresponding definitions.  These
   annotations are used by the code generation pass to generate code
   for variable references.

   If a semantic error is detected, |annotate| raises the exception
   |Sem_error|.  There is no way of resuming the analysis, and only
   one error can be detected per run of the compiler. *)

(* |annotate| -- check tree for type errors and annotate with definitions *)
val annotate : program -> unit

(* |Sem_error| -- exception raised on semantic error *)
exception Sem_error of string * Print.arg list * int

(* |regvars| -- whether to allocate register varaibles *)
val regvars : bool ref
