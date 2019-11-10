type token =
  | IDENT of (Tree.ident)
  | MULOP of (Keiko.op)
  | ADDOP of (Keiko.op)
  | RELOP of (Keiko.op)
  | NUMBER of (int)
  | SEMI
  | DOT
  | COLON
  | LPAR
  | RPAR
  | COMMA
  | ASSIGN
  | EOF
  | BADTOK
  | MINUS
  | AND
  | OR
  | NOT
  | BEGIN
  | END
  | IF
  | THEN
  | ELSIF
  | ELSE
  | CASE
  | OF
  | VBAR
  | LOOP
  | EXIT
  | REPEAT
  | UNTIL
  | WHILE
  | DO
  | PRINT
  | NEWLINE

val program :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Tree.program
