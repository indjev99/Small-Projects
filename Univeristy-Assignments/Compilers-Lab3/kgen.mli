(* lab3/kgen.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* |translate| -- generate intermediate code *)
val translate : Tree.program -> unit

val optflag : bool ref
