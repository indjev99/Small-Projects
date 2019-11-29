(* common/keiko.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Tree 
open Print

(* |codelab| -- type of code labels *)
type codelab = int

(* |lastlab| -- last used code label *)
let lastlab = ref 0

(* |label| -- allocate a code label *)
let label () = incr lastlab; !lastlab

(* |fLab| -- format a code label for printf *)
let fLab n = fMeta "L$" [fNum n]

(* |op| -- type of picoPascal operators *)
type op = Plus | Minus | Times | Div | Mod | Eq 
  | Uminus | Lt | Gt | Leq | Geq | Neq | And | Or | Not

(* |code| -- type of intermediate instructions *)
type code =
    CONST of int                (* Push constant (value) *)
  | GLOBAL of string            (* Push global address (name) *)
  | LOCAL of int                (* Push local adddress (offset) *)
  | LOADW                       (* Load word *)
  | STOREW                      (* Store word *)
  | LOADC                       (* Load character *)
  | STOREC                      (* Store character *)
  | MONOP of op                 (* Perform unary operation (op) *)
  | BINOP of op                 (* Perform binary operation (op) *)
  | OFFSET                      (* Add address and offset *)
  | LABEL of codelab            (* Set code label *)
  | JUMP of codelab             (* Unconditional branch (dest) *)
  | JUMPC of op * codelab       (* Conditional branch (op, dest) *)
  | PCALL of int                (* Call procedure *)
  | PCALLW of int               (* Proc call with result (nargs) *)
  | RETURNW                     (* Return from procedure *)
  | BOUND of int                (* Bounds check *)
  | CASEJUMP of int             (* Case jump (num cases) *)
  | CASEARM of int * codelab    (* Case value and label *)
  | PACK                        (* Pack two values into one *)
  | UNPACK                      (* Unpack one value into two *)
  | DUP
  | POP

  | LDGW of string              (* Load Global Word (name) *)
  | STGW of string              (* Store Global Word (name) *)
  | LDLW of int                 (* Load Local Word (offset) *)
  | STLW of int                 (* Store Local Word (offset) *)
  | LDNW of int                 (* Load word with offset *)
  | STNW of int                 (* Store word with offset *)

  | LINE of int
  | SEQ of code list
  | NOP

(* op_name -- map an operator to its name *)
let op_name =
  function
      Plus -> "Plus" | Minus -> "Minus" | Times -> "Times"
    | Div -> "Div" | Mod -> "Mod" | Eq -> "Eq"
    | Uminus -> "Uminus" | Lt -> "Lt" | Gt -> "Gt" 
    | Leq -> "Leq" | Geq -> "Geq" | Neq -> "Neq" 
    | And -> "And" | Or -> "Or" | Not -> "Not"

(* fOp -- format an operator as an instruction *)
let fOp w =
  (* Avoid the deprecated String.uppercase *)
  let upc ch =
    if ch >= 'a' && ch <= 'z' then Char.chr (Char.code ch - 32) else ch in
  fStr (String.map upc (op_name w))

(* |fInst| -- format an instruction for |printf| *)
let fInst =
  function
      CONST x ->        fMeta "CONST $" [fNum x]
    | GLOBAL a ->       fMeta "GLOBAL $" [fStr a]
    | LOCAL n ->        fMeta "LOCAL $" [fNum n]
    | LOADW ->          fStr "LOADW"
    | STOREW ->         fStr "STOREW"
    | LOADC ->          fStr "LOADC"
    | STOREC ->         fStr "STOREC"
    | MONOP w ->        fOp w
    | BINOP w ->        fOp w
    | OFFSET ->         fStr "OFFSET"
    | LABEL l ->        fMeta "LABEL $" [fLab l]
    | JUMP l ->         fMeta "JUMP $" [fLab l]
    | JUMPC (w, l) ->   fMeta "J$ $" [fOp w; fLab l]
    | PCALL n ->        fMeta "PCALL $" [fNum n]
    | PCALLW n ->       fMeta "PCALLW $" [fNum n]
    | RETURNW ->        fStr "RETURNW"
    | BOUND n ->        fMeta "BOUND $" [fNum n]
    | CASEJUMP n ->     fMeta "CASEJUMP $" [fNum n]
    | CASEARM (v, l) -> fMeta "CASEARM $ $" [fNum v; fLab l]
    | PACK ->           fStr "PACK"
    | UNPACK ->         fStr "UNPACK"
    | DUP ->            fStr "DUP 0"
    | POP ->            fStr "POP 1"
    | LDGW a ->         fMeta "LDGW $" [fStr a]
    | STGW a ->         fMeta "STGW $" [fStr a]
    | LDLW n ->         fMeta "LDLW $" [fNum n]
    | STLW n ->         fMeta "STLW $" [fNum n]
    | LDNW n ->         fMeta "LDNW $" [fNum n]
    | STNW n ->         fMeta "STNW $" [fNum n]
    | LINE n ->         fMeta "LINE $" [fNum n]
    | SEQ _ ->          fStr "SEQ ..."
    | NOP ->            fStr "NOP"

let mark_line n ys =
  if n = 0 then ys else
    match ys with
        [] | LINE _ :: _ -> ys
      | _ -> LINE n :: ys

(* |canon| -- flatten a code sequence *)
let canon x =
  let rec accum x ys =
    match x with
        SEQ xs -> List.fold_right accum xs ys
      | NOP -> ys
      | LINE n -> 
          if n = 0 then 
            ys 
          else begin
            match ys with
                [] -> ys
              | LINE _ :: _ -> ys
              | _ -> LINE n :: ys
          end
      | _ -> x :: ys in
  SEQ (accum x [])


(* SANITY CHECKS *)

(* The checks implemented here ensure that the value stack is used in a 
   consistent way, and that CASEJUMP instructions are followed by the 
   correct number of case labels.  There are a few assumptions, the main
   one being that backwards jumps leave nothing on the stack. *)

(* Compute pair (a, b) if an instruction pops a values and pushes b *)
let delta =
  function
      CONST _ | GLOBAL _ | LOCAL _ | LDGW _ | LDLW _ -> (0, 1)
    | STGW _ | STLW _ -> (1, 0)
    | LOADW | LOADC | LDNW _ -> (1, 1)
    | STOREW | STOREC | STNW _ -> (2, 0)
    | MONOP _ -> (1, 1)
    | BINOP _ | OFFSET -> (2, 1)
    | PCALL n -> (n+2, 0)
    | PCALLW n -> (n+2, 1)
    | RETURNW -> (1, 0)
    | BOUND _ -> (2, 1)
    | PACK -> (2, 1)
    | UNPACK -> (1, 2)
    | LINE _ -> (0, 0)
    | DUP -> (1, 2)
    | POP -> (1, 0)
    | i -> failwith (sprintf "delta $" [fInst i])

(* Output code and check for basic sanity *)
let check_and_output code =
  let line = ref 0 in

  (* Output an instruction *)
  let out =
    function 
        LINE n -> 
          if n <> 0 && !line <> n then begin
            printf "! $\n" [fStr (Source.get_line n)];
            line := n
          end
      | x -> printf "$\n" [fInst x] in

  (* Report failure of sanity checks *)
  let insane fmt args =
    fprintf stderr "WARNING: Code failed sanity checks -- $\n" [fMeta fmt args];
    printf "! *** HERE!\n" [];
    raise Exit in

  (* Map labels to (depth, flag) pairs *)
  let labdict = Hashtbl.create 50 in

  (* Note the depth at a label and check for consistency *)
  let note_label lab def d =
    try 
      let (d1, f) = Hashtbl.find labdict lab in
      if d >= 0 && d <> d1 then
        insane "inconsistent stack depth ($ <> $) at label $" 
          [fNum d; fNum d1; fNum lab];
      if def then begin
        if !f then insane "multiply defined label $" [fNum lab];
        f := true
      end;
      d1
    with Not_found ->
      (* If this point is after an unconditional jump (d < 0) and 
         the label is not defined previously, assume depth 0 *)
      let d1 = max d 0 in
      Hashtbl.add labdict lab (d1, ref def);
      d1 in

  (* Check all mentioned labels have been defined *)
  let check_labs () =
    Hashtbl.iter (fun lab (d, f) -> 
      if not !f then insane "label $ is not defined" [fNum lab]) labdict in

  let tail = ref [] in

  let output () = out (List.hd !tail); tail := List.tl !tail in

  (* Scan an instruction sequence, keeping track of the stack depth *)
  let rec scan d = 
    match !tail with
        [] -> 
          if d <> 0 then insane "stack not empty at end" []
      | x :: _ ->
          let need a =
            if d < a then 
              insane "stack underflow at instruction $" [fInst x] in
          output ();
          begin match x with
              LABEL lab -> 
                scan (note_label lab true d)
            | JUMP lab -> 
                unreachable (note_label lab false d)
            | JUMPC (_, lab) -> 
                need 2; scan (note_label lab false (d-2))
            | CASEARM (_, _) -> 
                insane "unexpected CASEARM" []
            | CASEJUMP n -> 
                need 1; jumptab n (d-1)
            | SEQ _ | NOP -> 
                failwith "sanity2"
            | _ -> 
                let (a, b) = delta x in need a; scan (d-a+b)
          end

  (* Scan a jump table, checking for the correct number of entries *)
  and jumptab n d =
    match !tail with
        CASEARM (_, lab) :: _ -> 
          output ();
          if n = 0 then
            insane "too many CASEARMs after CASEJUMP" [];
          jumptab (n-1) (note_label lab false d)
      | _ -> 
          if n > 0 then
            insane "too few CASEARMs after CASEJUMP" [];
          scan d

  (* Scan code after an unconditional jump *)
  and unreachable d =
    match !tail with
        [] -> ()
      | LABEL lab :: _ ->
          output ();
          scan (note_label lab true (-1))
      | _ -> 
          (* Genuinely unreachable code -- assume stack is empty *)
          scan 0 in

  match canon code with
      SEQ xs -> 
        tail := xs; 
        (try scan 0; check_labs () with Exit -> 
          (* After error, output rest of code without checks *)
          List.iter out !tail; exit 1)
    | _ -> failwith "sanity"

let output code = 
  try check_and_output code with Exit -> exit 1
    
