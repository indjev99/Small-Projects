(* lab4/regs.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

open Target

(* |init| -- initialise register state *)
val init : unit -> unit

(* |is_free| -- test if register is free *)
val is_free : reg -> bool

(* |get_regvars| -- reserve register variables *)
val get_regvars : int -> unit

(* |alloc_reg| -- allocate any register *)
val alloc_reg : unit -> reg

(* |get_reg| -- use specified register or allocate one if R_any *)
val get_reg : reg -> reg

(* |reserve_reg| -- reserve a register *)
val reserve_reg : reg -> unit

(* |release_reg| -- decrement reference count of register *)
val release_reg : reg -> unit

(* |dump_regs| -- make one-line summary of register state *)
val dump_regs : unit -> string


(* Temps *)

(* |new_temp| -- allocate a temp with specified reference count *)
val new_temp : int -> int

(* |inc_temp| -- increment refcount of a temp variable *)
val inc_temp : int -> unit

(* |use_temp| -- use a temp variable *)
val use_temp : int -> reg

(* |def_temp| -- define a temp variable *)
val def_temp : int -> reg -> unit

(* |spill_temps| -- move any temps that use specified registers to safety *)
val spill_temps : reg list -> unit

