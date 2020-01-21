(* lab4/dict.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(* This module defines the types that represent definitions and Pascal 
   types in the semantic analyser, and provides an abstract data type of
   'environments' used in the analyser.  There are also some functions that
   operate on types. *)

(* |ident| -- type of identifiers *)
type ident

(* |intern| -- convert string to identifier *)
val intern : string -> ident

(* |spelling| -- retrieve identifier as string *)
val spelling : ident -> string

(* |fId| -- format identifier for printing *)
val fId : ident -> Print.arg

(* |location| -- runtime locations *)
type location =
    Local of int                (* Local (offset) *)
  | Global of Optree.symbol     (* Global (label) *)
  | Register of int             (* Register *)
  | Nowhere                     (* Compile-time only *)

(* |Loc| -- printf format for locations *)
val fLoc: location -> Print.arg

(* |libid| -- type of picoPascal library procedures *)
type libid = ChrFun | OrdFun | PrintNum | PrintChar | PrintString 
  | NewLine | ReadChar | ExitProc | NewProc | ArgcFun | ArgvProc
  | OpenIn | CloseIn | Operator of Optree.op

val fLibId : libid -> Print.arg

(* |def_kind| -- kinds of definition *)
type def_kind = 
    ConstDef of int             (* Constant (value) *)
  | StringDef                   (* String constant *)
  | TypeDef                     (* Type *)
  | VarDef                      (* Variable *)
  | CParamDef                   (* Value parameter *)
  | VParamDef                   (* Var parameter *)
  | FieldDef                    (* Field of record *)
  | ProcDef                     (* Procedure *)
  | PParamDef                   (* Proc parameter *)
  | LibDef of libproc           (* Lib proc (data) *)
  | HoleDef of ptype ref        (* Pending type *)
  | DummyDef                    (* Dummy *)

(* |def| -- definitions in environment *)
and def = 
  { d_tag: ident;               (* Name *)
    d_kind: def_kind;           (* Kind of object *)
    d_type: ptype;              (* Type *)
    d_level: int;               (* Static level *)
    mutable d_mem: bool;        (* Whether addressible *)
    mutable d_addr: location }  (* Run-time location *)

and basic_type = VoidType | IntType | CharType | BoolType | AddrType

(* |ptype| -- picoPascal types *)
and ptype = 
  { t_id: int;                  (* Unique identifier *)
    t_guts: type_guts;          (* Shape of the type *)
    t_rep: Mach.metrics }       (* Runtime representation *)

and type_guts =
    BasicType of basic_type
  | ArrayType of int * ptype
  | RecordType of def list
  | ProcType of proc_data
  | PointerType of ptype ref

(* |proc_data| -- data about a procedure type *)
and proc_data =
  { p_fparams: def list;
    p_pcount : int;
    p_result: ptype }

(* |libproc| -- data about a library procedure *)
and libproc =
  { q_id: libid;
    q_nargs: int;
    q_argtypes: ptype list }

val offset_of : def -> int

val integer : ptype
val character : ptype
val boolean : ptype
val voidtype : ptype
val addrtype : ptype

type environment

(* |new_block| -- add a new top block *)
val new_block : environment -> environment

(* |add_block| -- add an existing def list as top block *)
val add_block : def list -> environment -> environment

(* |top_block| -- return top block as a def list *)
val top_block : environment -> def list

(* |define| -- add a definition, raise Exit if already declared *)
val define : def -> environment -> environment

(* |replace| -- replace tentative definition with final definition *)
val replace : def -> environment -> environment

(* |find_def| -- search a def list or raise Not_found *)
val find_def : ident -> def list -> def

(* |lookup| -- search an environment or raise Not_found *)
val lookup : ident -> environment -> def

(* |empty| -- empty environment *)
val empty : environment


(* Here are some functions that operate on types.  The chief one is the
   function |same_type| that tests whether two types are the same; it
   uses name equivalence.

   |match_args| checks two formal paramter lists for 'congurence', i.e.,
   that corresponding parameters have the same types, and that value
   parameters are not confused with var parameters.  This test is used
   for procedures that take other procedures as parameters. *)

(* |row| -- construct array type *)
val row : int -> ptype -> ptype

(* |mk_type| -- construct new (uniquely labelled) type *)
val mk_type : type_guts -> Mach.metrics -> ptype

(* |discrete| -- test if a type has discrete values *)
val discrete : ptype -> bool

(* |scalar| -- test if a type is simple *)
val scalar : ptype -> bool

(* |is_string| -- test if a type is 'array N of char' *)
val is_string : ptype -> bool

(* |bound| -- get bound of array type *)
val bound : ptype -> int

(* |is_pointer| -- test if a type is 'pointer to T' *)
val is_pointer : ptype -> bool

(* |base_type| -- get base type of pointer or array *)
val base_type : ptype -> ptype

(* |get_proc| -- get data from procedure type *)
val get_proc : ptype -> proc_data

(* |same_type| -- test two types for equality (name equivalence) *)
val same_type : ptype -> ptype -> bool

(* |match_args| -- test two formal parameter lists for congruence *)
val match_args : def list -> def list -> bool

