(* lab4/mach.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(*
This module contains a number of constants that define the layout of
data in the target machine.  The |metrics| records |int_rep|, etc.,
define the representation of the primitive types of picoPascal;
|param_rep| defines the representation of procedure parameters, and
|proc_rep| defines the representation of closures.

|addr_size| is the size of an address in the target machine,
|param_size| is the size of a parameter, and |max_align| is the
maximum alignment constraint of any primitive type.  Arrays and
records are always aligned to a multiple of |max_align|, so that all
their elements will be correctly aligned.  |frame_head level| is the
size of the fixed part of a procedure frame for static level
|level|.  
*)

(* |metrics| -- target representation of data object *)
type metrics = 
  { r_size: int;                (* Size of object *)
    r_align: int }              (* Address must be multiple of this *)

val int_rep : metrics           (* Integer type *)
val char_rep : metrics          (* Char type *)
val bool_rep : metrics          (* Boolean type *)
val void_rep : metrics          (* Void type *)
val addr_rep : metrics          (* All addresses *)
val proc_rep : metrics          (* Closures *)
val param_rep : metrics         (* Procedure parameters *)
val max_align : int

val param_base : int            (* +ve offset of first param from fp *)
val local_base : int            (* -ve offset of bottom of frame head *)
val stat_link : int             (* Offset of static link *)
val nregvars : int              (* Number of register variables *)
val share_globals : bool        (* Whether to use CSE on <GLOBAL x> *)

val comment : string            (* Comment prefix for assembler *)
