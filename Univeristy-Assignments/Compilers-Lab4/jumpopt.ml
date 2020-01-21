(* lab4/jumpopt.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Optree

(* Disjoint sets of labels *)

type labdata = 
    LabDef of labrec                    (* An extant label *)
  | Equiv of codelab                    (* A label that's been merged *)

and labrec = 
  { y_id : codelab;                     (* Name of the label *)
    y_refct : int ref }                 (* Reference count *)

let label_tab = Hashtbl.create 257

(* |get_label| -- find or create a label *)
let get_label x =
  try Hashtbl.find label_tab x with
    Not_found -> 
      let y = LabDef { y_id = x; y_refct = ref 0 } in
      Hashtbl.add label_tab x y; y

(* |find_label| -- find equivalent of a label *)
let rec find_label x =
  match get_label x with
      LabDef y -> y
    | Equiv x' -> find_label x'

let rename x = let y = find_label x in y.y_id

let ref_count x = let y = find_label x in y.y_refct

(* same_lab -- test if two labels are equal *)
let same_lab x1 x2 =
  let y1 = find_label x1 and y2 = find_label x2 in
  y1.y_id = y2.y_id

(* equate -- make two labels equal *)
let equate x1 x2 =
  let y1 = find_label x1 and y2 = find_label x2 in
  if y1.y_id = y2.y_id then failwith "equate";
  y2.y_refct := !(y1.y_refct) + !(y2.y_refct);
  Hashtbl.add label_tab y1.y_id (Equiv y2.y_id)  

(* do_refs -- call function on each label *)
let do_refs f =
  function
      <JUMP x> -> f (ref_count x)
    | <JUMPC (w, x), _, _> -> f (ref_count x)
    | <JCASE (labs, def), _> -> 
        List.iter (fun x -> f (ref_count x)) labs;
        f (ref_count def)
    | _ -> ()

(* rename_labs -- replace each label by its equivalent *)
let rename_labs =
  function
      <LABEL x> -> <LABEL (rename x)>
    | <JUMP x> -> <JUMP (rename x)>
    | <JUMPC (w, x), t1, t2> -> <JUMPC (w, rename x), t1, t2>
    | <JCASE (labs, def), t1> ->
        <JCASE (List.map rename labs, rename def), t1>
    | t -> t

(* optstep -- optimise to fixpoint at current location *)
let optstep changed code =
  let ch = ref true in

  let replace n inserted = 
    changed := true; ch := true;
    let deleted = Util.take n !code in
    List.iter (do_refs decr) deleted;
    List.iter (do_refs incr) inserted; 
    code := inserted @ Util.drop n !code in

  let delete n = replace (n+1) (Util.take n !code) in

  while !ch do
    ch := false;
    match !code with
        <JUMP lab1> :: <LABEL lab2> :: _ -> 
          (* Remove a jump to the next instruction *)
          if same_lab lab1 lab2 then delete 0
      | <JUMP lab1> :: <LINE n> :: <LABEL lab2> :: _ ->
          (* Keep a potentially useful line number *)
          replace 3 [<JUMP lab1>; <LABEL lab2>; <LINE n>]
      | <JUMP lab> :: _ :: _ -> 
          (* Eliminate dead code *)
          delete 1
      | <JUMPC (w, lab1), t1, t2> :: <JUMP lab2> :: <LABEL lab3> :: _ ->
          (* Simplify a jump over a jump *)
          if same_lab lab1 lab3 then
            replace 2 [<JUMPC (negate w, lab2), t1, t2>]
      | <LABEL lab1> :: <JUMP lab2> :: _ -> 
          (* One jump leads to another *)
          if not (same_lab lab1 lab2) then begin
            delete 0; equate lab1 lab2
          end
      | <LABEL lab1> :: <LABEL lab2> :: _ ->
          (* Merge identical labels *)
          delete 0; equate lab1 lab2
      | <LABEL lab> :: _ ->
          (* Delete unused labels *)
          if !(ref_count lab) = 0 then delete 0

      (* Tidy up line numbers *)
      | <LINE m> :: <LINE n> :: _ ->
          delete 0
      | <LINE n> :: <LABEL lab> :: _ ->
          replace 2 [<LABEL lab>; <LINE n>]
      | <LINE n> :: <JUMP lab> :: _ ->
          replace 2 [<JUMP lab>; <LINE n>]
      | <LINE n> :: [] ->
          delete 0
      | <NOP> :: _ ->
          delete 0

      | _ -> ()
  done

let optimise prog =
  Hashtbl.clear label_tab;
  let init = prog in
  List.iter (do_refs incr) init;
  let buf1 = ref init and buf2 = ref [] in
  let changed = ref true in
  while !changed do
    changed := false;
    while !buf1 <> [] do
      optstep changed buf1;
      if !buf1 <> [] then begin
        buf2 := List.hd !buf1 :: !buf2;
        buf1 := List.tl !buf1
      end
    done;
    buf1 := List.rev !buf2;
    buf2 := []
  done;
  List.map rename_labs !buf1

