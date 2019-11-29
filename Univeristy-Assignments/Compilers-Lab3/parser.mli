type token =
  | IDENT of (string)
  | NUMBER of (int)
  | MONOP of (Keiko.op)
  | MULOP of (Keiko.op)
  | ADDOP of (Keiko.op)
  | RELOP of (Keiko.op)
  | MINUS
  | LPAR
  | RPAR
  | COMMA
  | SEMI
  | DOT
  | ASSIGN
  | EOF
  | BADTOK
  | BEGIN
  | END
  | VAR
  | PRINT
  | IF
  | THEN
  | ELSE
  | WHILE
  | DO
  | PROC
  | RETURN
  | NEWLINE

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Tree.program
