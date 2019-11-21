(* lab2/lexer.mll *)
(* Copyright (c) 2017 J. M. Spivey *)

{
open Keiko
open Parser 
open Tree 
open Lexing 

let lineno = ref 1

let make_hash n ps =
  let t = Hashtbl.create n in
  List.iter (fun (k, v) -> Hashtbl.add t k v) ps;
  t

(* A little table to recognize keywords *)
let kwtable = 
  make_hash 64
    [ ("begin", BEGIN); ("do", DO); ("if", IF ); ("else", ELSE); 
      ("end", END); ("then", THEN);
      ("var", VAR); ("while", WHILE); ("print", PRINT); ("newline", NEWLINE);
      ("integer", INTEGER); ("boolean", BOOLEAN); ("array", ARRAY); 
      ("of", OF); ("true", BOOLCONST 1); ("false",  BOOLCONST 0);
      ("and", MULOP And); ("div", MULOP Div); ("or", ADDOP Or);
      ("not", MONOP Not); ("mod", MULOP Mod) ]

let lookup s = 
  try Hashtbl.find kwtable s with Not_found -> IDENT s
}

rule token = 
  parse
      ['A'-'Z''a'-'z']['A'-'Z''a'-'z''0'-'9''_']* as s
                        { lookup s }
    | ['0'-'9']+ as s   { NUMBER (int_of_string s) }
    | ";"               { SEMI }
    | "."               { DOT }
    | ":"               { COLON }
    | "("               { LPAR }
    | ")"               { RPAR }
    | "["               { SUB }
    | "]"               { BUS }
    | ","               { COMMA }
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
    | "\n"              { incr lineno; Source.note_line !lineno lexbuf;
                          token lexbuf }
    | _                 { BADTOK }
    | eof               { EOF }

and comment = parse
      "*)"              { () }
    | "\n"              { incr lineno; Source.note_line !lineno lexbuf;
                          comment lexbuf }
    | _                 { comment lexbuf }
    | eof               { () }

