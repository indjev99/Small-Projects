(* lab4/lexer.mll *)
(* Copyright (c) 2017 J. M. Spivey *)

{
open Print
open Optree
open Dict
open Parser
open Lexing
open Source

let lineno = ref 1                      (* Current line in input file *)

let symtable = 
  Util.make_hash 100
    [ ("array", ARRAY); ("begin", BEGIN);
      ("const", CONST); ("do", DO); ("if", IF ); ("else", ELSE); 
      ("end", END); ("of", OF); ("proc", PROC); ("record", RECORD);
      ("return", RETURN); ("then", THEN); ("to", TO);
      ("type", TYPE); ("var", VAR); ("while", WHILE);
      ("pointer", POINTER); ("nil", NIL);
      ("repeat", REPEAT); ("until", UNTIL); ("for", FOR);
      ("elsif", ELSIF); ("case", CASE);
      ("and", MULOP And); ("div", MULOP Div); ("or", ADDOP Or);
      ("not", NOT); ("mod", MULOP Mod) ]

let lookup s =
  try Hashtbl.find symtable s with
    Not_found ->
      let t = IDENT (intern s) in
      Hashtbl.add symtable s t; t

(* |strtbl| -- table of string constants from source program *)
let strtbl = ref []

(* |get_string| -- convert a string constant *)
let get_string s =
  let lab = gensym () in
  let n = String.length s in
  let s' = Bytes.create n
  and i = ref 0 and j = ref 0 in
  while !i <> n do
    let c = s.[!i] in
    Bytes.set s' !j c;
    if c = '"' then incr i;
    incr i; incr j
  done;
  strtbl := (lab, Bytes.sub_string s' 0 !j)::!strtbl;
  STRING (lab, !j)

(* |string_table| -- return contents of string table *)
let string_table () = List.rev !strtbl

let next_line lexbuf =
  incr lineno; Source.note_line !lineno lexbuf
}

(* This lexer uses two conventions that are supported by recent versions
of ocamllex: named regular expressions, and variables that are bound to
substrings of the token. *)

let letter = ['A'-'Z''a'-'z']

let digit = ['0'-'9']

let q = '\''
let qq = '"'
let notq = [^'\'']
let notqq = [^'"']

rule token = 
  parse
      letter (letter | digit | '_')* as s
                        { lookup s }
    | digit+ as s       { NUMBER (int_of_string s) }
    | q (notq as c) q   { CHAR c }
    | q q q q           { CHAR '\'' }
    | qq ((notqq | qq qq)* as s) qq     
                        { get_string s }
    | ";"               { SEMI }
    | "."               { DOT }
    | "|"               { VBAR }
    | ":"               { COLON }
    | "^"               { ARROW }
    | "("               { LPAR }
    | ")"               { RPAR }
    | ","               { COMMA }
    | "["               { SUB }
    | "]"               { BUS }
    | "="               { EQUAL }
    | "+"               { ADDOP Plus }
    | "-"               { MINUS }
    | "*"               { MULOP Times }
    | "<"               { RELOP Lt }
    | ">"               { RELOP Gt }
    | "<>"              { RELOP Neq }
    | "<="              { RELOP Leq }
    | ">="              { RELOP Geq }
    | ":="              { ASSIGN }
    | [' ''\t']+        { token lexbuf }
    | "(*"              { comment lexbuf; token lexbuf }
    | "\r"              { token lexbuf }
    | "\n"              { next_line lexbuf; token lexbuf }
    | _                 { BADTOK }
    | eof               { err_message "unexpected end of file" [] !lineno; 
                          exit 1 }

and comment = 
  parse
      "*)"              { () }
    | "\n"              { next_line lexbuf; comment lexbuf }
    | _                 { comment lexbuf }
    | eof               { err_message "end of file in comment" [] !lineno; 
                          exit 1 }

