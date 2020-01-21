(* lab4/simp.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* The simplifier runs over the trees in a forest, looking for algebraic
   simplifications such as constant folding.  It's mostly directed towards
   tidying up addressing calculations. *)

(* |optimise| -- clean up a forest *)
val optimise : Optree.optree list -> Optree.optree list
