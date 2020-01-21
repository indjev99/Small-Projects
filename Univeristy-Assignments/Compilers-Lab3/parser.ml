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

open Parsing;;
let _ = parse_error;;
# 14 "parser.mly"
open Keiko
open Tree
# 36 "parser.ml"
let yytransl_const = [|
  263 (* MINUS *);
  264 (* LPAR *);
  265 (* RPAR *);
  266 (* COMMA *);
  267 (* SEMI *);
  268 (* DOT *);
  269 (* ASSIGN *);
    0 (* EOF *);
  270 (* BADTOK *);
  271 (* BEGIN *);
  272 (* END *);
  273 (* VAR *);
  274 (* PRINT *);
  275 (* IF *);
  276 (* THEN *);
  277 (* ELSE *);
  278 (* WHILE *);
  279 (* DO *);
  280 (* PROC *);
  281 (* RETURN *);
  282 (* NEWLINE *);
    0|]

let yytransl_block = [|
  257 (* IDENT *);
  258 (* NUMBER *);
  259 (* MONOP *);
  260 (* MULOP *);
  261 (* ADDOP *);
  262 (* RELOP *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\003\000\003\000\006\000\006\000\004\000\004\000\
\007\000\009\000\009\000\005\000\010\000\010\000\011\000\011\000\
\011\000\011\000\011\000\011\000\011\000\011\000\013\000\013\000\
\014\000\014\000\012\000\012\000\015\000\015\000\015\000\016\000\
\016\000\017\000\017\000\017\000\017\000\017\000\017\000\008\000\
\000\000"

let yylen = "\002\000\
\002\000\005\000\000\000\003\000\001\000\003\000\000\000\002\000\
\006\000\002\000\003\000\001\000\001\000\003\000\000\000\003\000\
\002\000\005\000\007\000\005\000\002\000\001\000\002\000\003\000\
\001\000\003\000\001\000\003\000\001\000\003\000\003\000\001\000\
\003\000\001\000\001\000\002\000\002\000\002\000\003\000\001\000\
\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\041\000\000\000\000\000\000\000\000\000\
\001\000\000\000\000\000\000\000\000\000\004\000\040\000\000\000\
\000\000\008\000\006\000\000\000\000\000\000\000\000\000\000\000\
\000\000\022\000\000\000\000\000\012\000\000\000\010\000\000\000\
\000\000\034\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\032\000\000\000\000\000\000\000\002\000\000\000\000\000\
\011\000\000\000\037\000\038\000\000\000\000\000\036\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\014\000\009\000\
\039\000\023\000\000\000\000\000\000\000\000\000\000\000\033\000\
\000\000\000\000\000\000\024\000\018\000\000\000\020\000\026\000\
\000\000\019\000"

let yydgoto = "\002\000\
\004\000\005\000\006\000\011\000\027\000\008\000\012\000\038\000\
\021\000\029\000\030\000\067\000\055\000\068\000\040\000\041\000\
\042\000"

let yysindex = "\047\000\
\032\255\000\000\062\255\000\000\064\255\056\255\099\255\109\255\
\000\000\120\255\126\255\056\255\062\255\000\000\000\000\102\255\
\000\255\000\000\000\000\113\255\129\255\125\255\125\255\125\255\
\125\255\000\000\115\255\130\255\000\000\133\255\000\000\136\255\
\032\255\000\000\125\255\125\255\125\255\134\255\140\255\131\255\
\143\255\000\000\033\255\014\255\140\255\000\000\125\255\000\255\
\000\000\137\255\000\000\000\000\058\255\116\255\000\000\125\255\
\125\255\125\255\125\255\000\255\000\255\140\255\000\000\000\000\
\000\000\000\000\036\255\141\255\131\255\143\255\143\255\000\000\
\250\254\135\255\125\255\000\000\000\000\000\255\000\000\000\000\
\138\255\000\000"

let yyrindex = "\000\000\
\253\254\000\000\000\000\000\000\000\000\142\255\128\255\000\000\
\000\000\000\000\000\000\142\255\000\000\000\000\000\000\000\000\
\118\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\114\255\000\000\000\000\
\253\254\000\000\000\000\000\000\000\000\024\255\251\254\084\255\
\049\255\000\000\000\000\000\000\041\255\000\000\000\000\050\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\050\255\118\255\095\255\000\000\000\000\
\000\000\000\000\144\255\000\000\092\255\068\255\076\255\000\000\
\000\000\000\000\000\000\000\000\000\000\118\255\000\000\000\000\
\000\000\000\000"

let yygindex = "\000\000\
\000\000\116\000\000\000\140\000\219\255\023\000\000\000\246\255\
\000\000\107\000\000\000\236\255\000\000\081\000\102\000\212\255\
\229\255"

let yytablesize = 158
let yytable = "\016\000\
\015\000\039\000\043\000\044\000\045\000\021\000\028\000\051\000\
\052\000\077\000\021\000\003\000\070\000\071\000\078\000\021\000\
\053\000\022\000\023\000\056\000\003\000\024\000\073\000\074\000\
\025\000\026\000\062\000\035\000\035\000\035\000\035\000\072\000\
\035\000\035\000\035\000\019\000\061\000\028\000\056\000\035\000\
\081\000\056\000\032\000\035\000\035\000\075\000\035\000\001\000\
\003\000\028\000\028\000\017\000\060\000\029\000\029\000\029\000\
\017\000\029\000\029\000\029\000\015\000\017\000\007\000\056\000\
\029\000\015\000\065\000\028\000\029\000\029\000\015\000\029\000\
\030\000\030\000\030\000\009\000\030\000\030\000\030\000\010\000\
\031\000\031\000\031\000\030\000\031\000\031\000\031\000\030\000\
\030\000\027\000\030\000\031\000\027\000\027\000\027\000\031\000\
\031\000\028\000\031\000\027\000\028\000\028\000\028\000\027\000\
\027\000\016\000\027\000\028\000\013\000\020\000\016\000\028\000\
\028\000\007\000\028\000\016\000\015\000\034\000\035\000\014\000\
\015\000\031\000\036\000\037\000\066\000\015\000\034\000\035\000\
\015\000\013\000\046\000\036\000\037\000\015\000\013\000\057\000\
\005\000\058\000\005\000\033\000\017\000\054\000\047\000\048\000\
\049\000\056\000\059\000\064\000\050\000\076\000\079\000\018\000\
\025\000\082\000\063\000\080\000\007\000\069\000"

let yycheck = "\010\000\
\001\001\022\000\023\000\024\000\025\000\011\001\017\000\035\000\
\036\000\016\001\016\001\015\001\057\000\058\000\021\001\021\001\
\037\000\018\001\019\001\006\001\024\001\022\001\060\000\061\000\
\025\001\026\001\047\000\004\001\005\001\006\001\007\001\059\000\
\009\001\010\001\011\001\013\000\023\001\048\000\006\001\016\001\
\078\000\006\001\020\000\020\001\021\001\010\001\023\001\001\000\
\017\001\060\000\061\000\011\001\020\001\005\001\006\001\007\001\
\016\001\009\001\010\001\011\001\011\001\021\001\001\001\006\001\
\016\001\016\001\009\001\078\000\020\001\021\001\021\001\023\001\
\005\001\006\001\007\001\012\001\009\001\010\001\011\001\024\001\
\005\001\006\001\007\001\016\001\009\001\010\001\011\001\020\001\
\021\001\006\001\023\001\016\001\009\001\010\001\011\001\020\001\
\021\001\006\001\023\001\016\001\009\001\010\001\011\001\020\001\
\021\001\011\001\023\001\016\001\010\001\008\001\016\001\020\001\
\021\001\001\001\023\001\021\001\001\001\002\001\003\001\011\001\
\001\001\009\001\007\001\008\001\009\001\001\001\002\001\003\001\
\011\001\016\001\016\001\007\001\008\001\016\001\021\001\005\001\
\009\001\007\001\011\001\011\001\015\001\008\001\013\001\011\001\
\009\001\006\001\004\001\011\001\033\000\009\001\016\001\012\000\
\009\001\016\001\048\000\075\000\015\001\056\000"

let yynames_const = "\
  MINUS\000\
  LPAR\000\
  RPAR\000\
  COMMA\000\
  SEMI\000\
  DOT\000\
  ASSIGN\000\
  EOF\000\
  BADTOK\000\
  BEGIN\000\
  END\000\
  VAR\000\
  PRINT\000\
  IF\000\
  THEN\000\
  ELSE\000\
  WHILE\000\
  DO\000\
  PROC\000\
  RETURN\000\
  NEWLINE\000\
  "

let yynames_block = "\
  IDENT\000\
  NUMBER\000\
  MONOP\000\
  MULOP\000\
  ADDOP\000\
  RELOP\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'block) in
    Obj.repr(
# 21 "parser.mly"
                                        ( Program _1 )
# 220 "parser.ml"
               : Tree.program))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'var_decl) in
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'proc_decls) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'stmts) in
    Obj.repr(
# 24 "parser.mly"
                                         ( Block (_1, _2, _4) )
# 229 "parser.ml"
               : 'block))
; (fun __caml_parser_env ->
    Obj.repr(
# 27 "parser.mly"
                                        ( [] )
# 235 "parser.ml"
               : 'var_decl))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ident_list) in
    Obj.repr(
# 28 "parser.mly"
                                        ( _2 )
# 242 "parser.ml"
               : 'var_decl))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 31 "parser.mly"
                                        ( [_1] )
# 249 "parser.ml"
               : 'ident_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : string) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'ident_list) in
    Obj.repr(
# 32 "parser.mly"
                                        ( _1::_3 )
# 257 "parser.ml"
               : 'ident_list))
; (fun __caml_parser_env ->
    Obj.repr(
# 35 "parser.mly"
                                        ( [] )
# 263 "parser.ml"
               : 'proc_decls))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'proc_decl) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'proc_decls) in
    Obj.repr(
# 36 "parser.mly"
                                        ( _1::_2 )
# 271 "parser.ml"
               : 'proc_decls))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 4 : 'name) in
    let _3 = (Parsing.peek_val __caml_parser_env 3 : 'formals) in
    let _5 = (Parsing.peek_val __caml_parser_env 1 : 'block) in
    Obj.repr(
# 39 "parser.mly"
                                        ( Proc (_2, _3, _5) )
# 280 "parser.ml"
               : 'proc_decl))
; (fun __caml_parser_env ->
    Obj.repr(
# 42 "parser.mly"
                                        ( [] )
# 286 "parser.ml"
               : 'formals))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'ident_list) in
    Obj.repr(
# 43 "parser.mly"
                                        ( _2 )
# 293 "parser.ml"
               : 'formals))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'stmt_list) in
    Obj.repr(
# 46 "parser.mly"
                                        ( seq _1 )
# 300 "parser.ml"
               : 'stmts))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 49 "parser.mly"
                                        ( [_1] )
# 307 "parser.ml"
               : 'stmt_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'stmt) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'stmt_list) in
    Obj.repr(
# 50 "parser.mly"
                                        ( _1::_3 )
# 315 "parser.ml"
               : 'stmt_list))
; (fun __caml_parser_env ->
    Obj.repr(
# 53 "parser.mly"
                                        ( Skip )
# 321 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'name) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 54 "parser.mly"
                                        ( Assign (_1, _3) )
# 329 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 55 "parser.mly"
                                        ( Return _2 )
# 336 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'stmts) in
    Obj.repr(
# 56 "parser.mly"
                                        ( IfStmt (_2, _4, Skip) )
# 344 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'stmts) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'stmts) in
    Obj.repr(
# 57 "parser.mly"
                                        ( IfStmt (_2, _4, _6) )
# 353 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'stmts) in
    Obj.repr(
# 58 "parser.mly"
                                        ( WhileStmt (_2, _4) )
# 361 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 59 "parser.mly"
                                        ( Print _2 )
# 368 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 60 "parser.mly"
                                        ( Newline )
# 374 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 63 "parser.mly"
                                        ( [] )
# 380 "parser.ml"
               : 'actuals))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr_list) in
    Obj.repr(
# 64 "parser.mly"
                                        ( _2 )
# 387 "parser.ml"
               : 'actuals))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 67 "parser.mly"
                                        ( [_1] )
# 394 "parser.ml"
               : 'expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr_list) in
    Obj.repr(
# 68 "parser.mly"
                                        ( _1::_3 )
# 402 "parser.ml"
               : 'expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple) in
    Obj.repr(
# 71 "parser.mly"
                                        ( _1 )
# 409 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Keiko.op) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'simple) in
    Obj.repr(
# 72 "parser.mly"
                                        ( Binop (_2, _1, _3) )
# 418 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'term) in
    Obj.repr(
# 75 "parser.mly"
                                        ( _1 )
# 425 "parser.ml"
               : 'simple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Keiko.op) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'term) in
    Obj.repr(
# 76 "parser.mly"
                                        ( Binop (_2, _1, _3) )
# 434 "parser.ml"
               : 'simple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'term) in
    Obj.repr(
# 77 "parser.mly"
                                        ( Binop (Minus, _1, _3) )
# 442 "parser.ml"
               : 'simple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'factor) in
    Obj.repr(
# 80 "parser.mly"
                                        ( _1 )
# 449 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'term) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Keiko.op) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'factor) in
    Obj.repr(
# 81 "parser.mly"
                                        ( Binop (_2, _1, _3) )
# 458 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 84 "parser.mly"
                                        ( Constant _1 )
# 465 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'name) in
    Obj.repr(
# 85 "parser.mly"
                                        ( Variable _1 )
# 472 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'name) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'actuals) in
    Obj.repr(
# 86 "parser.mly"
                                        ( Call (_1, _2) )
# 480 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Keiko.op) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'factor) in
    Obj.repr(
# 87 "parser.mly"
                                        ( Monop (_1, _2) )
# 488 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'factor) in
    Obj.repr(
# 88 "parser.mly"
                                        ( Monop (Uminus, _2) )
# 495 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 89 "parser.mly"
                                        ( _2 )
# 502 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 92 "parser.mly"
                                        ( makeName _1 !Lexer.lineno )
# 509 "parser.ml"
               : 'name))
(* Entry program *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let program (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Tree.program)
