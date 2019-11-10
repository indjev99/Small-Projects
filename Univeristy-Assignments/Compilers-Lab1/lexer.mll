(* lab1/lexer.mll *)
(* Copyright (c) 2017 J. M. Spivey *)

{
open Lexing
open Tree 
open Keiko
open Parser

(* |lineno| -- line number for use in error messages *)
let lineno = ref 1

(* |make_hash| -- create hash table from list of pairs *)
let make_hash n ps =
  let t = Hashtbl.create n in
  List.iter (fun (k, v) -> Hashtbl.add t k v) ps;
  t

(* |kwtable| -- a little table to recognize keywords *)
let kwtable = 
  make_hash 64
    [ ("begin", BEGIN); ("end", END); ("if", IF ); ("then", THEN);("elsif", ELSIF);
      ("else", ELSE); ("case", CASE); ("of", OF); ("loop", LOOP); ("exit", EXIT);
      ("while", WHILE); ("do", DO); ("repeat", REPEAT); ("until", UNTIL);
      ("print", PRINT); ("newline", NEWLINE); ("div", MULOP Div);
      ("mod", MULOP Mod); ("not", NOT); ("and", AND);
      ("or", OR); ("true", NUMBER 1); ("false", NUMBER 0) ]

(* |idtable| -- table of all identifiers seen so far *)
let idtable = Hashtbl.create 64

(* |lookup| -- convert string to keyword or identifier *)
let lookup s = 
  try Hashtbl.find kwtable s with 
    Not_found -> 
      Hashtbl.replace idtable s ();
      IDENT s

(* |get_vars| -- get list of identifiers in the program *)
let get_vars () = 
  Hashtbl.fold (fun k () ks -> k::ks) idtable []
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
    | ","               { COMMA }
    | "="               { RELOP Eq }
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
    | "|"               { VBAR }
    | _                 { BADTOK }
    | eof               { EOF }

and comment = 
  parse
      "*)"              { () }
    | "\n"              { incr lineno; Source.note_line !lineno lexbuf;
                          comment lexbuf }
    | _                 { comment lexbuf }
    | eof               { () }
