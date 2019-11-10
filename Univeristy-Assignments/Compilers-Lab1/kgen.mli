(* lab1/kgen.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* translate -- generate intermediate code *)
val translate : Tree.program -> unit

(* optflag -- flag to control optimisation *)
val optflag : bool ref
