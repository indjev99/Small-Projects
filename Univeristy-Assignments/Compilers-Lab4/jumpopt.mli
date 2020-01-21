(* lab4/jumpopt.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* The jump optimiser looks for multiple labels on the same tree,
   jumps that lead to jumps, and other simple patterns in control flow. *)

(* |optimise| -- clean up a forest *)
val optimise : Optree.optree list -> Optree.optree list
