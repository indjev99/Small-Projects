(* ppc/peepopt.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Keiko
open Print

let debug = ref 0

(* Disjoint sets of labels *)

type lab_data = 
    LabDef of labrec                    (* An extant label *)
  | Equiv of codelab                    (* A label that's been merged *)

and labrec =
  { y_id: codelab;                      (* Name of the label *)
    y_refct: int ref }                  (* Reference count *)

(* |label_tab| -- map labels to their equivalents *)
let label_tab = Hashtbl.create 257

(* |get_label| -- get equivalence cell for a label *)
let get_label x =
  try !(Hashtbl.find label_tab x) with
    Not_found ->
      let y = LabDef { y_id = x; y_refct = ref 0 } in
      Hashtbl.add label_tab x (ref y); y

(* |find_label| -- find data about equivalence class of a label *)
let rec find_label x =
  match get_label x with
      LabDef y -> y
    | Equiv x' -> find_label x'

(* |rename| -- get canonical equivalent of a label *)
let rename x = let y = find_label x in y.y_id

(* |ref_count| -- get reference count cell for a label *)
let ref_count x = let y = find_label x in y.y_refct

(* |same_lab| -- test if two labels are equivalent *)
let same_lab x1 x2 = (rename x1 = rename x2)

(* |equate| -- make two labels equivalent *)
let equate x1 x2 =
  let y1 = find_label x1 and y2 = find_label x2 in
  if y1.y_id = y2.y_id then failwith "equate";
  y2.y_refct := !(y1.y_refct) + !(y2.y_refct);
  Hashtbl.find label_tab y1.y_id := Equiv y2.y_id

(* |do_refs| -- call function on refcount of each label in an instruction *)
let do_refs f =
  function
      JUMP x -> f (ref_count x)
    | JUMPC (w, x) -> f (ref_count x)
    | CASEARM (n, x) -> f (ref_count x)
    | _ -> ()

(* |rename_labs| -- replace each label by its equivalent *)
let rename_labs =
  function
      LABEL x -> LABEL (rename x)
    | JUMP x -> JUMP (rename x)
    | JUMPC (w, x) -> JUMPC (w, rename x)
    | CASEARM (n, x) -> CASEARM (n, rename x)
    | i -> i

let opposite =
  function Eq -> Neq | Neq -> Eq | Lt  -> Geq
    | Leq -> Gt | Gt  -> Leq | Geq -> Lt
    | _ -> failwith "opposite"

(* |ruleset| -- simplify and introduce abbreviations *)
let ruleset replace =
  function
      LOCAL a :: CONST b :: OFFSET :: _ ->
        replace 3 [LOCAL (a+b)]
    | CONST a :: OFFSET :: CONST b :: OFFSET :: _ ->
        replace 4 [CONST (a+b); OFFSET]
    | CONST 0 :: OFFSET :: _ ->
        replace 2 []
     
    | GLOBAL x :: LOADW :: _ ->
        replace 2 [LDGW x]
    | GLOBAL x :: STOREW :: _ ->
        replace 2 [STGW x]
    | LOCAL n :: LOADW :: _ ->
        replace 2 [LDLW n]
    | LOCAL n :: STOREW :: _ ->
        replace 2 [STLW n]
    | CONST n :: OFFSET :: LOADW :: _ ->
        replace 3 [LDNW n]
    | CONST n :: OFFSET :: STOREW :: _ ->
        replace 3 [STNW n]

    | CONST x :: CONST n :: BOUND _ :: _ when x >= 0 && x < n ->
        replace 3 [CONST x]

    | LINE n :: LABEL a :: _ ->
        replace 2 [LABEL a; LINE n]
    | LINE n :: LINE m :: _ ->
        replace 1 []
    | LABEL a :: LABEL b :: _ ->
        equate a b; replace 2 [LABEL a]
    | LABEL a :: JUMP b :: _ when not (same_lab a b) ->
        equate a b; replace 2 [JUMP b]
    | JUMPC (w, a) :: JUMP b :: LABEL c :: _ when same_lab a c ->
        replace 2 [JUMPC (opposite w, b)]
    | JUMP a :: LABEL b :: _ when same_lab a b ->
        replace 1 []
    | JUMP a :: LABEL b :: _ -> 
        ()
    | JUMP a :: _ :: _ ->
        replace 2 [JUMP a]
    | LABEL a :: _ when !(ref_count a) = 0 ->
        replace 1 []

    | _ -> ()

(* |take n [x1; x2; ...] = [x1; x2; ...; xn]| *)
let rec take n =
  function
      [] -> []
    | x::xs -> if n = 0 then [] else x :: take (n-1) xs

(* |drop n [x1; x2; ...] = [x_{n+1}; x_{n+2}; ...]| *)
let rec drop n =
  function
      [] -> []
    | x::xs -> if n = 0 then x::xs else drop (n-1) xs

(* |optstep| -- apply rules at one place in the buffer *)
let optstep rules changed code =
  let ch = ref true in
  let replace n c = 
    changed := true; ch := true;
  if !debug > 0 then
      printf "! $ --> $\n" [fList(fInst) (take n !code); fList(fInst) c];
    List.iter (do_refs decr) (take n !code);
    List.iter (do_refs incr) c; 
    code := c @ drop n !code in
  while !ch do
    ch := false; rules replace !code
  done

(* |rewrite| -- iterate over the code and apply rules *)
let rewrite rules prog =
  let code1 = ref prog and code2 = ref [] in
  let changed = ref true in
  while !changed do
    changed := false;
    while !code1 <> [] do
      optstep rules changed code1;
      if !code1 <> [] then begin
        code2 := rename_labs (List.hd !code1) :: !code2;
        code1 := List.tl !code1
      end
    done;
    code1 := List.rev !code2;
    code2 := []
  done;
  !code1

(* |optimise| -- rewrite list of instructions *)
let optimise prog =
  match Keiko.canon prog with
      SEQ code ->
        List.iter (do_refs incr) code;
        let code2 = rewrite ruleset code in
        Hashtbl.clear label_tab;
        SEQ code2
    | _ -> failwith "optimise"
