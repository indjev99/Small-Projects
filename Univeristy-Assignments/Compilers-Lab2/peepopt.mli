(* ppc/peepopt.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* |optimise| -- rewrite list of instructions *)
val optimise : Keiko.code -> Keiko.code

(* |debug| -- debugging level *)
val debug: int ref
