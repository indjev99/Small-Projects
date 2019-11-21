(* lab2/dict.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

(* Environments are implemented using a library module that 
   represents mappings by balanced binary trees. *)

type ident = string

type ptype = 
    Integer 
  | Boolean 
  | Array of int * ptype
  | Void

(* |is_array| -- returns whether the type is an array *)
let is_array =
  function
      Array _ -> true
    | _ -> false

(* |array_length| -- returns the length of an array *)
let array_length =
  function
      Array (n, _) -> n
    | _ -> failwith "array_length called with not array"

(* |type_size| -- returns the size in bytes of the type *)
let rec type_size =
  function
      Integer -> 4
    | Boolean -> 1
    | Array (n, t) -> n * type_size t
    | Void -> 0

(* |base_type| -- returns the base type of an array *)
let rec base_type =
  function
      Array (_, t) -> t
    | _ -> failwith "base_type called with not array"

(* |root_type| -- returns the root type of a type *)
let rec root_type =
  function
      Array (_, t) -> root_type t
    | t -> t

(* |def| -- definitions in environment *)
type def = 
  { d_tag: ident;               (* Name *)
    d_type: ptype;              (* Type *)
    d_lab: string }             (* Global label *)

module IdMap = Map.Make(struct type t = ident  let compare = compare end)

type environment = Env of def IdMap.t

let can f x = try f x; true with Not_found -> false

(* |define| -- add a definition *)
let define d (Env e) = 
  if can (IdMap.find d.d_tag) e then raise Exit;
  Env (IdMap.add d.d_tag d e)

(* |lookup| -- find definition of an identifier *)
let lookup x (Env e) = IdMap.find x e

(* |init_env| -- empty environment *)
let init_env = Env IdMap.empty
