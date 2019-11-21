(* lab2/lexer.mli *)
(* Copyright (c) 2017 J. M. Spivey *)

(*
The lexer is generated from a camllex script.  It takes an input
buffer, reads a token, and returns the |token| value that corresponds
to it.  The lexer maintains the current line number in |lineno| for
producing error messages.
*)

(* |token| -- scan a token and return its code *)
val token : Lexing.lexbuf -> Parser.token

(* |lineno| -- number of current line *)
val lineno : int ref
