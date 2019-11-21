(* lab2/kgen.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* The intermediate code generator takes an abstract syntax tree that
   has been annotated by the semantic analyser, and produces abstract
   machine code.  No errors should be detected in this part if the
   compiler, unless earlier passes are broken. *)

(* |translate| -- generate intermediate code *)
val translate : Tree.program -> unit

val optflag : bool ref
