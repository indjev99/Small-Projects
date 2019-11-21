type token =
  | IDENT of (Dict.ident)
  | MULOP of (Keiko.op)
  | ADDOP of (Keiko.op)
  | RELOP of (Keiko.op)
  | MONOP of (Keiko.op)
  | NUMBER of (int)
  | BOOLCONST of (int)
  | SEMI
  | DOT
  | COLON
  | LPAR
  | RPAR
  | COMMA
  | EQUAL
  | MINUS
  | ASSIGN
  | EOF
  | BADTOK
  | SUB
  | BUS
  | BEGIN
  | DO
  | ELSE
  | END
  | IF
  | THEN
  | VAR
  | WHILE
  | PRINT
  | NEWLINE
  | ARRAY
  | OF
  | INTEGER
  | BOOLEAN

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Tree.program
