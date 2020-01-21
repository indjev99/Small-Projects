(* lab4/target.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Optree
open Print

(* |reg| -- type of ARM registers *)
type reg = R of int | R_fp | R_sp | R_pc | R_ip | R_any | R_temp | R_none

let reg_name =
  function
      R n -> sprintf "r$" [fNum n]
    | R_fp -> "fp" 
    | R_sp -> "sp"
    | R_pc -> "pc"
    | R_ip -> "ip"   
    | R_any -> "*ANYREG*" 
    | R_temp -> "*TEMPREG*"
    | R_none -> "*NOREG*"

(* |fReg| -- format register for printing *)
let fReg r = fStr (reg_name r)

(* ARM register assignments:

   R0-3   arguments + scratch
   R4-R9  callee-save temps
   R10    static link
   R11=fp frame pointer
   R12=sp stack pointer
   R13=ip temp for linkage
   R14=lr link register
   R15=pc program counter 

*)

let volatile = [R 0; R 1; R 2; R 3; R 10]
let stable = [R 4; R 5; R 6; R 7; R 8; R 9]

(* |operand| -- type of operands for assembly instructions *)
type operand =                  (* VALUE        ASM SYNTAX       *)
    Const of int                (* val          #val             *)
  | Register of reg             (* [reg]        reg              *)
  | Index of reg * int          (* [reg]+val    [reg, #val]      *)
  | Index2 of reg * reg * int   (* [r1]+[r2]<<n [r1, r2, LSL #n] *)
  | Shift of reg * int          (* reg<<n       reg, LSL #n      *)
  | Global of symbol            (* lab          lab              *)
  | Label of codelab            (* lab          lab              *)

(* |fRand| -- format operand for printing *)
let fRand =
  function
      Const v -> fMeta "#$" [fNum v]
    | Register reg -> fReg reg
    | Index (reg, off) ->
        if off = 0 then fMeta "[$]" [fReg reg]
        else fMeta "[$, #$]" [fReg reg; fNum off]
    | Index2 (r1, r2, n) ->
        if n = 0 then
          fMeta "[$, $]" [fReg r1; fReg r2]
        else
          fMeta "[$, $, LSL #$]" [fReg r1; fReg r2; fNum n]
    | Shift (reg, n) ->
        if n = 0 then
          fMeta "$" [fReg reg]
        else
          fMeta "$, LSL #$" [fReg reg; fNum n]
    | Global lab -> fStr lab
    | Label lab -> fMeta ".$" [fLab lab]

(* |reg_of| -- extract register (or R_none) from operand *)
let reg_of = 
  function
      Register reg -> reg
    | _ -> failwith "reg_of"

(* |seg| -- type of assembler segments *)
type seg = Text | Data | Unknown

(* |current_seg| -- current output segment *)
let current_seg = ref Unknown

(* |segment| -- emit segment directive if needed *)
let segment s =
  if !current_seg <> s then begin
    let seg_name = 
      match s with 
        Text -> ".text" | Data -> ".data" | Unknown -> "*unknown*" in
    printf "\t$\n" [fStr seg_name];
    current_seg := s
  end

(* |preamble| -- emit start of assembler file *)
let preamble () =
  printf "@ picoPascal compiler output\n" [];
  printf "\t.include \"fixup.s\"\n" [];
  printf "\t.global pmain\n\n" []

type item = 
    Instr of string * operand list 
  | Label of codelab
  | Comment of string
  | Tree of Optree.optree

let code = Queue.create ()
let icount = ref 0

let frame = ref 0
let stack = ref 0

(* |emit| -- emit an assembly language instruction *)
let emit inst rands =
  incr icount;
  Queue.add (Instr (inst, rands)) code

let move_reg dst src =
  emit "mov" [Register dst; Register src]

(* |emit_lab| -- emit a label *)
let emit_lab lab =
  Queue.add (Label lab) code

let emit_comment cmnt =
  Queue.add (Comment cmnt) code

let emit_tree t =
  Queue.add (Tree t) code

let need_stack n =
  stack := max n !stack

let flush () =
  let put =
    function
        Instr (inst, []) -> 
          printf "\t$\n" [fStr inst]
      | Instr (inst, rands) ->
          printf "\t$ $\n" [fStr inst; fList(fRand) rands]
      | Label lab ->
          printf ".$:\n" [fLab lab] 
      | Comment cmnt ->
          printf "@ $\n" [fStr cmnt] 
      | Tree t ->
          Optree.print_optree "@ " t in
  Queue.iter put code;
  Queue.clear code

(* |start_proc| -- emit start of procedure *)
let start_proc lab nargs fram =
  segment Text;
  printf "$:\n" [fStr lab];
  printf "\tmov ip, sp\n" [];
  if nargs > 0 then begin
    let save = if nargs <= 2 then "{r0-r1}" else "{r0-r3}" in
    printf "\tstmfd sp!, $\n" [fStr save]
  end;
  printf "\tstmfd sp!, {r4-r10, fp, ip, lr}\n" [];
  printf "\tmov fp, sp\n" [];
  frame := fram

(* |flush_proc| -- output procedure fragment, perhaps after error *)
let flush_proc () =
  (* Round up frame space for stack alignment *)
  let space = 8 * ((!frame + !stack + 7)/8) in
  if space <= 1024 then
    (* Since space is a multiple of 8, we can fit values up to 1024 *)
    (if space > 0 then printf "\tsub sp, sp, #$\n" [fNum space])
  else begin
    printf "\tset ip, #$\n" [fNum space];
    printf "\tsub sp, sp, ip\n" []
  end;
  flush ();
  stack := 0

(* |end_proc| -- emit end of procedure *)
let end_proc () =
  flush_proc ();
  printf "\tldmfd fp, {r4-r10, fp, sp, pc}\n" [];
  printf "\t.ltorg\n" [];               (* Output the literal table *)
  printf "\n" []

(* |emit_string| -- output a string constant *)
let emit_string lab s =
  segment Data;
  printf "$:" [fStr lab];
  let n = String.length s in
  for k = 0 to n-1 do
    let c = int_of_char s.[k] in
    if k mod 10 = 0 then 
      printf "\n\t.byte $" [fNum c]
    else
      printf ", $" [fNum c]
  done;
  printf "\n\t.byte 0\n" []

(* |emit_global| -- output a global variable *)
let emit_global lab n =
  printf "\t.comm $, $, 4\n" [fStr lab; fNum n]

(* |postamble| -- finish the assembler file *)
let postamble () =
  fprintf stderr "$ instructions\n" [fNum !icount];
  printf "@ End\n" []

