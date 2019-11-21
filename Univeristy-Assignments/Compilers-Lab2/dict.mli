(* lab2/dict.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

type ident = string

type ptype = 
    Integer 
  | Boolean 
  | Array of int * ptype
  | Void

(* |is_array| -- returns whether the type is an array *)
val is_array : ptype -> bool

(* |array_length| -- returns the length of an array *)
val array_length : ptype -> int

(* |type_size| -- returns the size in bytes of the type *)
val type_size : ptype -> int

(* |base_type| -- returns the base type of an array *)
val base_type : ptype -> ptype

(* |root_type| -- returns the root type of a type *)
val root_type : ptype -> ptype

(* |def| -- definitions in environment *)
type def = 
  { d_tag: ident;               (* Name *)
    d_type: ptype;              (* Type *)
    d_lab: string }             (* Global label *)

type environment

(* |define| -- add a definition, raise Exit if already declared *)
val define : def -> environment -> environment

(* |lookup| -- search an environment or raise Not_found *)
val lookup : ident -> environment -> def

(* |init_env| -- initial empty environment *)
val init_env : environment
