(* lab4/check.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Optree
open Tree
open Dict
open Print
open Lexer
open Mach

(* EXPRESSIONS *)

(* A few global variables to save passing parameters everywhere *)

(* Nesting level of current procedure *)
let level = ref 0

(* Return type of current procedure *)
let return_type = ref voidtype

(* Whether to allocate register variables *)
let regvars = ref true

(* Line number to use when reporting errors *)
let err_line = ref 1

(* Exception raised when a semantic error is detected *)
exception Sem_error of string * Print.arg list * int

(* |sem_error| -- report a semantic error and abandon analysis *)
let sem_error fmt args =
  raise (Sem_error (fmt, args, !err_line))

(* |expr_fail| -- report type error in most unhelpful way possible *)
let expr_fail () = sem_error "type error in expression" []

(* |lookup_def| -- find definition of a name, give error if none *)
let lookup_def x env =
  err_line := x.x_line;
  try 
    let d = lookup x.x_name env in 
    x.x_def <- Some d; d
  with Not_found -> 
    sem_error "$ is not declared" [fId x.x_name]

(* |add_def| -- add definition to envmt, give error if already declared *)
let add_def d env =
  try define d env with 
    Exit -> sem_error "$ is already declared" [fId d.d_tag]

(* |check_monop| -- check application of unary operator *)
let check_monop w t =
  match w with
      Uminus ->
        if not (same_type t integer) then expr_fail ();
        integer
    | Not ->
        if not (same_type t boolean) then expr_fail ();
        boolean
    | _ -> failwith "bad monop"

(* |check_binop| -- check application of binary operator *)
let check_binop w t1 t2 =
  match w with
      Plus | Minus | Times | Div | Mod ->
        if not (same_type t1 integer && same_type t2 integer) then
          expr_fail ();
        integer
    | Eq | Lt | Gt | Leq | Geq | Neq ->
        if not (scalar t1) || not (same_type t1 t2) then expr_fail ();
        boolean
    | And | Or ->
        if not (same_type t1 boolean && same_type t2 boolean) then
          expr_fail ();
        boolean
    | _ -> failwith "bad binop"

(* |try_monop| -- propagate constant through unary operation *)
let try_monop w =
  function
      Some x -> Some (do_monop w x) 
    | None -> None

(* |try_binop| -- propagate constant through unary operation *)
let try_binop w v1 v2 =
  match (v1, v2) with 
      (Some x1, Some x2) -> Some (do_binop w x1 x2)
    | _ -> None

(* |has_value| -- check if object is suitable for use in expressions *)
let has_value d = 
  match d.d_kind with
      ConstDef _ | VarDef | CParamDef | VParamDef | StringDef -> true 
    | _ -> false

(* |check_var| -- check that expression denotes a variable *)
let rec check_var e addressible =
  match e.e_guts with
      Variable x ->
        let d = get_def x in
        begin
          match d.d_kind with 
              VarDef | VParamDef | CParamDef ->
                d.d_mem <- d.d_mem || addressible
            | _ -> 
                sem_error "$ is not a variable" [fId x.x_name]
        end
    | Sub (a, i) -> check_var a addressible
    | Select (r, x) -> check_var r addressible
    | Deref p -> ()
    | _ -> sem_error "a variable is needed here" []

(* |check_expr| -- check and annotate an expression, return its type *)
let rec check_expr e env =
  let t = expr_type e env in
  e.e_type <- t; t

(* |expr_type| -- return type of expression *)
and expr_type e env =
  match e.e_guts with
      Variable x -> 
        let d = lookup_def x env in 
        if not (has_value d) then
          sem_error "$ is not a variable" [fId x.x_name];
        if d.d_level < !level then d.d_mem <- true;
        begin
          match d.d_kind with 
              ConstDef v ->
                e.e_value <- Some v 
            | _ -> ()
        end;
        d.d_type
    | Sub (e1, e2) ->
        let t1 = check_expr e1 env
        and t2 = check_expr e2 env in
        if not (same_type t2 integer) then
          sem_error "subscript is not an integer" [];
        begin
          match t1.t_guts with
              ArrayType (upb, u1) -> u1
            | _ -> sem_error "subscripting a non-array" []
        end
    | Select (e1, x) ->
        let t1 = check_expr e1 env in
        err_line := x.x_line;
        begin
          match t1.t_guts with
            RecordType fields ->
              let d = try find_def x.x_name fields
                with Not_found ->
                  sem_error "selecting non-existent field" [] in
              x.x_def <- Some d; d.d_type
          | _ -> sem_error "selecting from a non-record" []
        end
    | Deref e1 ->
        let t1 = check_expr e1 env in
        begin
          match t1.t_guts with
              PointerType u -> !u
            | _ -> sem_error "dereferencing a non-pointer" []
        end
    | Constant (n, t) -> e.e_value <- Some n; t
    | String (lab, n) -> row n character
    | Nil -> e.e_value <- Some 0; addrtype
    | FuncCall (p, args) -> 
        let v = ref None in
        let t1 = check_funcall p args env v in
        if same_type t1 voidtype then
          sem_error "$ does not return a result" [fId p.x_name];
        e.e_value <- !v; t1
    | Monop (w, e1) -> 
        let t = check_monop w (check_expr e1 env) in
        e.e_value <- try_monop w e1.e_value;
        t
    | Binop (w, e1, e2) -> 
        let t = check_binop w (check_expr e1 env) (check_expr e2 env) in
        e.e_value <- try_binop w e1.e_value e2.e_value;
        t

(* |check_funcall| -- check a function or procedure call *)
and check_funcall f args env v =
  let d = lookup_def f env in
  match d.d_kind with
      LibDef q ->
        check_libcall q args env v; d.d_type
    | ProcDef | PParamDef ->
        let p = get_proc d.d_type in
        check_args p.p_fparams args env; 
        p.p_result
    | _ -> sem_error "$ is not a procedure" [fId f.x_name]

(* |check_args| -- match formal and actual parameters *)
and check_args formals args env =
  try List.iter2 (fun f a -> check_arg f a env) formals args with
    Invalid_argument _ ->
      sem_error "wrong number of arguments" []

(* |check_arg| -- check one (formal, actual) parameter pair *)
and check_arg formal arg env =
  match formal.d_kind with
      CParamDef | VParamDef ->
        let t1 = check_expr arg env in
        if not (same_type formal.d_type t1) then
          sem_error "argument has wrong type" [];
        if formal.d_kind = VParamDef then 
          check_var arg true
    | PParamDef ->
        let pf = get_proc formal.d_type in
        let x = (match arg.e_guts with Variable x -> x 
          | _ -> sem_error "procedure argument must be a proc name" []) in
        let actual = lookup_def x env in
        begin
          match actual.d_kind with 
              ProcDef | PParamDef  ->
                let pa = get_proc actual.d_type in
                if not (match_args pf.p_fparams pa.p_fparams) then
                  sem_error "argument lists don't match" [];
                if not (same_type pf.p_result pa.p_result) then
                  sem_error "result types don't match" []
            | _ -> 
                sem_error "argument $ is not a procedure" [fId x.x_name]
        end
    | _ -> failwith "bad formal"

(* |check_libcall| -- check call to a library procedure *)
and check_libcall q args env v =
  (* |q.q_nargs = -1| if the lib proc has a variable number of arguments;
     otherwise it is the number of arguments.  |q.q_argtypes = []| if the
     argument types can vary; otherwise it is a list of arg types. *)
  if q.q_nargs >= 0 && List.length args <> q.q_nargs then
    sem_error "wrong number of arguments for $" [fLibId q.q_id];
  if q.q_argtypes <> [] then begin
    let check t e =
      if not (same_type t (check_expr e env)) then
        sem_error "argument of $ has wrong type" [fLibId q.q_id] in
    List.iter2 check q.q_argtypes args
  end;
  match q.q_id with 
      ChrFun ->
        let e1 = List.hd args in
        v := e1.e_value
    | OrdFun ->
        let e1 = List.hd args in
        let t1 = check_expr e1 env in
        if not (discrete t1) then
          sem_error "ord expects an argument of a discrete type" [];
        v := e1.e_value
    | PrintString ->
        let t1 = check_expr (List.hd args) env in
        if not (is_string t1) then
          sem_error "print_string expects a string" []
    | ReadChar ->
        check_var (List.hd args) true
    | NewProc ->
        let t1 = check_expr (List.hd args) env in
        if not (is_pointer t1) then 
          sem_error "parameter of new must be a pointer" [];
        check_var (List.hd args) false
    | ArgvProc ->
        let t1 = check_expr (List.nth args 0) env
        and t2 = check_expr (List.nth args 1) env in
        if not (same_type t1 integer) || not (is_string t2) then
          sem_error "type error in parameters of argv" [];
        check_var (List.nth args 1) true
    | OpenIn ->
        let t1 = check_expr (List.nth args 0) env in
        if not (is_string t1) then
          sem_error "parameter of open_in is not a string" []
    | _ -> ()

(* |check_const| -- check an expression with constant value *)
let check_const e env =
  let t = check_expr e env in
  match e.e_value with
      Some v -> (t, v)
    | None -> sem_error "constant expected" []


(* STATEMENTS *)

let make_def x k t =
  { d_tag = x; d_kind = k; d_type = t; d_level = !level;
    d_mem = false; d_addr = Nowhere }

(* check_dupcases -- check for duplicate case labels *)
let check_dupcases vs =
  let rec chk = 
    function
        [] | [_] -> ()
      | x :: (y :: ys as rest) -> 
          if x = y then sem_error "duplicate case label" [];
          chk rest in
  chk (List.sort compare vs)

(* |check_stmt| -- check and annotate a statement *)
let rec check_stmt s env alloc =
  err_line := s.s_line;
  match s.s_guts with
      Skip -> ()

    | Seq ss ->
        List.iter (fun s1 -> check_stmt s1 env alloc) ss

    | Assign (lhs, rhs) ->
        let lt = check_expr lhs env
        and rt = check_expr rhs env in
        check_var lhs false;
        if not (same_type lt rt) then
          sem_error "type mismatch in assignment" []

    | ProcCall (p, args) ->
        let rt = check_funcall p args env (ref None) in
        if rt <> voidtype then
          sem_error "$ returns a result" [fId p.x_name]

    | Return res ->
        if !level = 0 then
          sem_error "return statement not allowed in main program" [];
        begin
          match res with
              Some e ->
                if same_type !return_type voidtype then
                  sem_error "procedure must not return a result" [];
                let t = check_expr e env in
                if not (same_type t !return_type) then
                  sem_error "type mismatch in return statement" []
            | None ->
                if not (same_type !return_type voidtype) then
                  sem_error "function must return a result" []
        end

    | IfStmt (cond, thenpt, elsept) ->
        let ct = check_expr cond env in
        if not (same_type ct boolean) then
          sem_error "test in if statement must be a boolean" []; 
        check_stmt thenpt env alloc;
        check_stmt elsept env alloc

    | WhileStmt (cond, body) ->
        let ct = check_expr cond env in
        if not (same_type ct boolean) then
          sem_error "type mismatch in while statement" [];
        check_stmt body env alloc

    | RepeatStmt (body, test) ->
        check_stmt body env alloc;
        let ct = check_expr test env in
        if not (same_type ct boolean) then
          sem_error "type mismatch in repeat statement" []

    | ForStmt (var, lo, hi, body, upb) ->
        let vt = check_expr var env in
        let lot = check_expr lo env in
        let hit = check_expr hi env in
        if not (same_type vt integer) || not (same_type lot integer)
            || not (same_type hit integer) then
          sem_error "type mismatch in for statement" [];
        check_var var false;
        check_stmt body env alloc;

        (* Allocate space for hidden variable.  In the code, this will
           be used to save the upper bound.  *)
        let d = make_def (intern "*upb*") VarDef integer in
        alloc d; upb := Some d

    | CaseStmt (sel, arms, deflt) ->
        let st = check_expr sel env in
        if not (scalar st) then
          sem_error "expression in case statement must be scalar" [];

        let check_arm (lab, body) =
          let (t1, v) = check_const lab env in
          if not (same_type t1 st) then
            sem_error "case label has wrong type" [];
          check_stmt body env alloc; v in

        let vs = List.map check_arm arms in
        check_dupcases vs;
        check_stmt deflt env alloc


(* TYPES AND DECLARATIONS *)

(* |lookup_typename| -- find a named type in the environment *)
let lookup_typename x env =
  let d = lookup_def x env in
  match d.d_kind with
      (TypeDef | HoleDef _) -> d
    | _ -> sem_error "$ is not a type" [fId x.x_name]

(* |align| -- increase offset to next multiple of alignment *)
let align alignment offset =
  let margin = !offset mod alignment in
  if margin <> 0 then offset := !offset - margin + alignment

(* upward_alloc -- allocate objects upward in memory *)
let upward_alloc size d =
  let r = d.d_type.t_rep in
  align r.r_align size;
  let addr = !size in
  size := !size + r.r_size;
  d.d_addr <- Local addr

(* local_alloc -- allocate locals downward in memory *)
let local_alloc size nreg d =
  if !regvars && not d.d_mem && scalar (d.d_type) 
      && !nreg < Mach.nregvars then begin
    d.d_addr <- Register !nreg; incr nreg
  end
  else begin
    let r = d.d_type.t_rep in
    align r.r_align size;
    size := !size + r.r_size;
    d.d_addr <- Local (local_base - !size)
  end

(* param_alloc -- allocate space for formal parameters *)
let param_alloc pcount d =
  let s = param_rep.r_size in
  match d.d_kind with
      CParamDef | VParamDef ->
        d.d_addr <- Local (param_base + s * !pcount);
        incr pcount
    | PParamDef ->
        d.d_addr <- Local (param_base + s * !pcount);
        pcount := !pcount + 2
    | _ -> failwith "param_alloc"

(* |global_alloc| -- allocate label for global variable *)
let global_alloc d =
  d.d_addr <- Global (sprintf "_$" [fId d.d_tag])

(* |do_alloc| -- call allocation function for definitions that need it *)
let do_alloc alloc ds =
  let h d =
    match d.d_kind with
        VarDef | CParamDef | VParamDef | FieldDef | PParamDef ->
          alloc d
      | _ -> () in
  List.iter h ds

(* |check_typexpr| -- check a type expression, returning the ptype *)
let rec check_typexpr te env = 
  match te with
      TypeName x ->
        let d = lookup_typename x env in
        if d.d_kind = TypeDef then d.d_type
        else sem_error "$ is used before its definition" [fId x.x_name]
    | Array (upb, value) ->
        let (t1, v1) = check_const upb env
        and t2 = check_typexpr value env in
        if not (same_type t1 integer) then
          sem_error "upper bound must be an integer" [];
        row v1 t2
    | Record fields ->
        let env' = check_decls fields (new_block env) in
        let defs = top_block env' in
        let size = ref 0 in
        do_alloc (upward_alloc size) defs;
        align max_align size;
        let r = { r_size = !size; r_align = max_align } in
        mk_type (RecordType defs) r
    | Pointer te ->
        let t = 
          match te with
              TypeName x ->
                let d = lookup_typename x env in
                begin
                  match d.d_kind with
                      TypeDef -> ref d.d_type
                    | HoleDef h -> h
                    | _ -> failwith "pointer"
                end
            | _ -> ref (check_typexpr te env) in
        mk_type (PointerType t) addr_rep

(* |check_decl| -- check a declaration and add it to the environment *)
and check_decl d env = 
  (* All types of declaration are mixed together in the AST *)
  match d with
      ConstDecl (x, e) ->
        begin
          match e.e_guts with
              String (lab, n) ->
                let t = row n character in
                let d = make_def x StringDef t in
                d.d_addr <- Global lab;
                add_def d env
            | _ ->
                let (t, v) = check_const e env in
                add_def (make_def x (ConstDef v) t) env
        end
    | VarDecl (kind, xs, te) ->
        let t = check_typexpr te env in
        let def x env = 
          let d = make_def x kind t in
          add_def d env in
        Util.accum def xs env
    | TypeDecl tds ->
        let tds' = 
          List.map (function (x, te) -> (x, te, ref voidtype)) tds in
        let add_hole (x, te, h) env1 =
          add_def (make_def x (HoleDef h) voidtype) env1 in
        let env' = Util.accum add_hole tds' env in
        let redefine (x, te, h) env1 =
          let t = check_typexpr te env1 in
          h := t; replace (make_def x TypeDef t) env1 in
        Util.accum redefine tds' env' 
    | ProcDecl (Heading (x, _, _) as heading, body) ->
        let t = check_heading env heading in
        let d = make_def x.x_name ProcDef t in
        d.d_addr <- Global (sprintf "_$" [fId d.d_tag]);
        x.x_def <- Some d; add_def d env
    | PParamDecl (Heading (x, _, _) as heading) ->
        let t = check_heading env heading in
        let d = make_def x.x_name PParamDef t in
        add_def d env
  
(* |check_heading| -- process a procedure heading into a procedure type *)
and check_heading env (Heading (x, fparams, result)) =
  err_line := x.x_line;
  incr level;
  let env' = check_decls fparams (new_block env) in
  let defs = top_block env' in
  let pcount = ref 0 in
  do_alloc (param_alloc pcount) defs;
  decr level;
  let rt = (match result with
              Some te -> check_typexpr te env | None -> voidtype) in
  if not (same_type rt voidtype) && not (scalar rt) then
    sem_error "return type must be scalar" [];
  let p = { p_fparams = defs; p_pcount = !pcount; p_result = rt } in
  mk_type (ProcType p) proc_rep

(* |check_decls| -- check a sequence of declarations *)
and check_decls ds env =
  Util.accum check_decl ds env

(* Storage is allocated for local variables in a separate phase from
   processing the declarations.  That makes it possible to gather
   additional innformation about the usage of variables (i.e., whether
   they must be addressible) before deciding which can live in
   registers. *)

(* |check_block| -- check a local block *)
let rec check_block level rt env (Block (ds, ss, fsize, nregv)) =
  let env' = check_decls ds (new_block env) in
  let defs = ref (top_block env') in
  let pre_alloc d = defs := !defs @ [d] in
  check_bodies env' ds;
  return_type := rt;
  check_stmt ss env' pre_alloc;
  do_alloc (local_alloc fsize nregv) !defs;
  align max_align fsize

(* |check_bodies| -- check bodies of procedure declarations *)
and check_bodies env ds = 
  let check =
    function
        ProcDecl (Heading(x, _, _), body) ->
          let d = get_def x in
          let p = get_proc d.d_type in
          let env' = add_block p.p_fparams env in
          incr level;
          check_block d.d_level p.p_result env' body;
          decr level
      | _ -> () in
  List.iter check ds


(* INITIAL ENVIRONMENT *)

let defn (x, k, t) env = 
  let d = { d_tag = intern x; d_kind = k; d_type = t;
            d_level = 0; d_mem = false; d_addr = Nowhere } in
  define d env

let libproc i n ts = 
  LibDef { q_id = i; q_nargs = n; q_argtypes = ts }

let operator op ts =
  libproc (Operator op) (List.length ts) ts

(* |init_env| -- environment for whole program *)
let init_env = 
  Util.accum defn
    [ ("integer", TypeDef, integer);
      ("char", TypeDef, character);
      ("boolean", TypeDef, boolean);
      ("true", ConstDef 1, boolean);
      ("false", ConstDef 0, boolean);
      ("chr", libproc ChrFun 1 [integer], character);
      ("ord", libproc OrdFun 1 [], integer);
      ("print_num", libproc PrintNum 1 [integer], voidtype);
      ("print_char", libproc PrintChar 1 [character], voidtype);
      ("print_string", libproc PrintString 1 [], voidtype);
      ("open_in", libproc OpenIn 1 [], boolean);
      ("close_in", libproc CloseIn 0 [], voidtype);
      ("newline", libproc NewLine 0 [], voidtype);
      ("read_char", libproc ReadChar 1 [character], voidtype);
      ("exit", libproc ExitProc 1 [integer], voidtype);
      ("new", libproc NewProc 1 [], voidtype);
      ("argc", libproc ArgcFun 0 [], integer);
      ("argv", libproc ArgvProc 2 [], voidtype);
      ("lsl", operator Lsl [integer; integer], integer);
      ("lsr", operator Lsr [integer; integer], integer);
      ("asr", operator Asr [integer; integer], integer);
      ("bitand", operator BitAnd [integer; integer], integer);
      ("bitor", operator BitOr [integer; integer], integer);
      ("bitnot", operator BitNot [integer], integer)] empty

(* |annotate| -- annotate the whole program *)
let annotate (Prog (Block (globals, ss, fsize, nregv), glodefs)) =
  level := 0;
  let env = check_decls globals (new_block init_env) in
  do_alloc global_alloc (top_block env);
  check_bodies env globals;
  return_type := voidtype;
  level := 1;
  let alloc = local_alloc fsize nregv in
  check_stmt ss env alloc;
  align max_align fsize;
  glodefs := top_block env
