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

open Parsing;;
let _ = parse_error;;
# 5 "parser.mly"
open Keiko
open Dict 
open Tree
# 44 "parser.ml"
let yytransl_const = [|
  264 (* SEMI *);
  265 (* DOT *);
  266 (* COLON *);
  267 (* LPAR *);
  268 (* RPAR *);
  269 (* COMMA *);
  270 (* EQUAL *);
  271 (* MINUS *);
  272 (* ASSIGN *);
    0 (* EOF *);
  273 (* BADTOK *);
  274 (* SUB *);
  275 (* BUS *);
  276 (* BEGIN *);
  277 (* DO *);
  278 (* ELSE *);
  279 (* END *);
  280 (* IF *);
  281 (* THEN *);
  282 (* VAR *);
  283 (* WHILE *);
  284 (* PRINT *);
  285 (* NEWLINE *);
  286 (* ARRAY *);
  287 (* OF *);
  288 (* INTEGER *);
  289 (* BOOLEAN *);
    0|]

let yytransl_block = [|
  257 (* IDENT *);
  258 (* MULOP *);
  259 (* ADDOP *);
  260 (* RELOP *);
  261 (* MONOP *);
  262 (* NUMBER *);
  263 (* BOOLCONST *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\004\000\005\000\005\000\006\000\006\000\
\006\000\003\000\008\000\008\000\009\000\009\000\009\000\009\000\
\009\000\009\000\009\000\011\000\011\000\011\000\012\000\012\000\
\012\000\013\000\013\000\014\000\014\000\014\000\014\000\014\000\
\014\000\010\000\010\000\007\000\000\000"

let yylen = "\002\000\
\005\000\000\000\002\000\005\000\001\000\003\000\001\000\001\000\
\004\000\001\000\001\000\003\000\000\000\003\000\002\000\001\000\
\005\000\007\000\005\000\001\000\003\000\003\000\001\000\003\000\
\003\000\001\000\003\000\001\000\001\000\001\000\002\000\002\000\
\003\000\001\000\004\000\001\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\037\000\000\000\000\000\036\000\000\000\
\000\000\000\000\003\000\000\000\000\000\000\000\000\000\000\000\
\016\000\000\000\034\000\010\000\000\000\000\000\000\000\007\000\
\008\000\000\000\006\000\000\000\029\000\030\000\000\000\000\000\
\000\000\000\000\000\000\000\000\026\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\004\000\031\000\000\000\032\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\001\000\
\012\000\000\000\000\000\000\000\033\000\000\000\000\000\000\000\
\000\000\000\000\027\000\000\000\035\000\009\000\000\000\017\000\
\019\000\000\000\018\000"

let yydgoto = "\002\000\
\004\000\005\000\018\000\006\000\008\000\026\000\019\000\020\000\
\021\000\033\000\034\000\035\000\036\000\037\000"

let yysindex = "\009\000\
\049\255\000\000\057\255\000\000\052\255\049\255\000\000\073\255\
\085\255\000\255\000\000\242\254\057\255\164\255\164\255\164\255\
\000\000\065\255\000\000\000\000\091\255\077\255\094\255\000\000\
\000\000\098\255\000\000\164\255\000\000\000\000\164\255\164\255\
\084\255\254\254\032\255\108\255\000\000\255\254\056\255\102\255\
\000\255\164\255\164\255\081\255\000\000\000\000\075\255\000\000\
\164\255\164\255\000\255\164\255\164\255\164\255\000\255\000\000\
\000\000\056\255\007\255\242\254\000\000\032\255\032\255\248\254\
\108\255\108\255\000\000\092\255\000\000\000\000\000\255\000\000\
\000\000\093\255\000\000"

let yyrindex = "\000\000\
\103\255\000\000\000\000\000\000\000\000\103\255\000\000\000\000\
\104\255\009\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\017\255\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\034\255\000\000\117\255\059\255\000\000\000\000\042\255\000\000\
\046\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\046\255\000\000\000\000\000\000\009\255\000\000\
\000\000\069\255\000\000\000\000\000\000\129\255\141\255\000\000\
\082\255\105\255\000\000\000\000\000\000\000\000\009\255\000\000\
\000\000\000\000\000\000"

let yygindex = "\000\000\
\000\000\112\000\210\255\000\000\109\000\072\000\063\000\093\000\
\000\000\246\255\247\255\250\255\255\255\232\255"

let yytablesize = 179
let yytable = "\022\000\
\007\000\049\000\049\000\046\000\064\000\038\000\039\000\048\000\
\068\000\001\000\049\000\050\000\050\000\071\000\072\000\023\000\
\013\000\024\000\025\000\055\000\050\000\047\000\051\000\014\000\
\074\000\069\000\015\000\016\000\017\000\067\000\022\000\013\000\
\058\000\059\000\052\000\028\000\028\000\028\000\011\000\011\000\
\022\000\028\000\062\000\063\000\022\000\028\000\053\000\028\000\
\028\000\015\000\065\000\066\000\028\000\013\000\028\000\028\000\
\028\000\007\000\028\000\049\000\022\000\023\000\023\000\015\000\
\015\000\009\000\023\000\013\000\013\000\050\000\023\000\010\000\
\023\000\023\000\003\000\009\000\014\000\023\000\049\000\023\000\
\023\000\023\000\012\000\023\000\024\000\024\000\061\000\040\000\
\050\000\024\000\014\000\014\000\042\000\024\000\043\000\024\000\
\024\000\013\000\041\000\044\000\024\000\043\000\024\000\024\000\
\024\000\045\000\024\000\025\000\025\000\054\000\056\000\060\000\
\025\000\005\000\073\000\075\000\025\000\011\000\025\000\025\000\
\020\000\027\000\002\000\025\000\020\000\025\000\025\000\025\000\
\020\000\025\000\020\000\070\000\021\000\057\000\000\000\020\000\
\021\000\020\000\020\000\020\000\021\000\020\000\021\000\000\000\
\022\000\000\000\000\000\021\000\022\000\021\000\021\000\021\000\
\022\000\021\000\022\000\000\000\000\000\000\000\000\000\022\000\
\000\000\022\000\022\000\022\000\007\000\022\000\000\000\000\000\
\028\000\029\000\030\000\000\000\000\000\000\000\031\000\000\000\
\000\000\000\000\032\000"

let yycheck = "\010\000\
\001\001\004\001\004\001\028\000\051\000\015\000\016\000\032\000\
\055\000\001\000\004\001\014\001\014\001\022\001\023\001\030\001\
\008\001\032\001\033\001\021\001\014\001\031\000\025\001\024\001\
\071\000\019\001\027\001\028\001\029\001\054\000\041\000\023\001\
\042\000\043\000\003\001\002\001\003\001\004\001\022\001\023\001\
\051\000\008\001\049\000\050\000\055\000\012\001\015\001\014\001\
\015\001\008\001\052\000\053\000\019\001\008\001\021\001\022\001\
\023\001\001\001\025\001\004\001\071\000\003\001\004\001\022\001\
\023\001\003\000\008\001\022\001\023\001\014\001\012\001\020\001\
\014\001\015\001\026\001\013\000\008\001\019\001\004\001\021\001\
\022\001\023\001\010\001\025\001\003\001\004\001\012\001\023\001\
\014\001\008\001\022\001\023\001\016\001\012\001\018\001\014\001\
\015\001\013\001\008\001\006\001\019\001\018\001\021\001\022\001\
\023\001\008\001\025\001\003\001\004\001\002\001\009\001\031\001\
\008\001\010\001\023\001\023\001\012\001\006\000\014\001\015\001\
\004\001\013\000\020\001\019\001\008\001\021\001\022\001\023\001\
\012\001\025\001\014\001\060\000\004\001\041\000\255\255\019\001\
\008\001\021\001\022\001\023\001\012\001\025\001\014\001\255\255\
\004\001\255\255\255\255\019\001\008\001\021\001\022\001\023\001\
\012\001\025\001\014\001\255\255\255\255\255\255\255\255\019\001\
\255\255\021\001\022\001\023\001\001\001\025\001\255\255\255\255\
\005\001\006\001\007\001\255\255\255\255\255\255\011\001\255\255\
\255\255\255\255\015\001"

let yynames_const = "\
  SEMI\000\
  DOT\000\
  COLON\000\
  LPAR\000\
  RPAR\000\
  COMMA\000\
  EQUAL\000\
  MINUS\000\
  ASSIGN\000\
  EOF\000\
  BADTOK\000\
  SUB\000\
  BUS\000\
  BEGIN\000\
  DO\000\
  ELSE\000\
  END\000\
  IF\000\
  THEN\000\
  VAR\000\
  WHILE\000\
  PRINT\000\
  NEWLINE\000\
  ARRAY\000\
  OF\000\
  INTEGER\000\
  BOOLEAN\000\
  "

let yynames_block = "\
  IDENT\000\
  MULOP\000\
  ADDOP\000\
  RELOP\000\
  MONOP\000\
  NUMBER\000\
  BOOLCONST\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 4 : 'decls) in
    let _3 = (Parsing.peek_val __caml_parser_env 2 : 'stmts) in
    Obj.repr(
# 32 "parser.mly"
                                        ( Program (_1, _3) )
# 242 "parser.ml"
               : Tree.program))
; (fun __caml_parser_env ->
    Obj.repr(
# 35 "parser.mly"
                                        ( [] )
# 248 "parser.ml"
               : 'decls))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'decl) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'decls) in
    Obj.repr(
# 36 "parser.mly"
                                        ( _1 :: _2 )
# 256 "parser.ml"
               : 'decls))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'name_list) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'typexp) in
    Obj.repr(
# 39 "parser.mly"
                                        ( Decl (_2, _4) )
# 264 "parser.ml"
               : 'decl))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'name) in
    Obj.repr(
# 42 "parser.mly"
                                        ( [_1] )
# 271 "parser.ml"
               : 'name_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'name) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'name_list) in
    Obj.repr(
# 43 "parser.mly"
                                        ( _1 :: _3 )
# 279 "parser.ml"
               : 'name_list))
; (fun __caml_parser_env ->
    Obj.repr(
# 46 "parser.mly"
                                        ( Integer )
# 285 "parser.ml"
               : 'typexp))
; (fun __caml_parser_env ->
    Obj.repr(
# 47 "parser.mly"
                                        ( Boolean )
# 291 "parser.ml"
               : 'typexp))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 2 : int) in
    let _4 = (Parsing.peek_val __caml_parser_env 0 : 'typexp) in
    Obj.repr(
# 48 "parser.mly"
                                        ( Array (_2, _4) )
# 299 "parser.ml"
               : 'typexp))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'stmt_list) in
    Obj.repr(
# 51 "parser.mly"
                                        ( seq _1 )
# 306 "parser.ml"
               : 'stmts))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'stmt) in
    Obj.repr(
# 54 "parser.mly"
                                        ( [_1] )
# 313 "parser.ml"
               : 'stmt_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'stmt) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'stmt_list) in
    Obj.repr(
# 55 "parser.mly"
                                        ( _1 :: _3 )
# 321 "parser.ml"
               : 'stmt_list))
; (fun __caml_parser_env ->
    Obj.repr(
# 58 "parser.mly"
                                        ( Skip )
# 327 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'variable) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 59 "parser.mly"
                                        ( Assign (_1, _3) )
# 335 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'expr) in
    Obj.repr(
# 60 "parser.mly"
                                        ( Print _2 )
# 342 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    Obj.repr(
# 61 "parser.mly"
                                        ( Newline )
# 348 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'stmts) in
    Obj.repr(
# 62 "parser.mly"
                                        ( IfStmt (_2, _4, Skip) )
# 356 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 5 : 'expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 3 : 'stmts) in
    let _6 = (Parsing.peek_val __caml_parser_env 1 : 'stmts) in
    Obj.repr(
# 63 "parser.mly"
                                        ( IfStmt (_2, _4, _6) )
# 365 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 3 : 'expr) in
    let _4 = (Parsing.peek_val __caml_parser_env 1 : 'stmts) in
    Obj.repr(
# 64 "parser.mly"
                                        ( WhileStmt (_2, _4) )
# 373 "parser.ml"
               : 'stmt))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'simple) in
    Obj.repr(
# 67 "parser.mly"
                                        ( _1 )
# 380 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Keiko.op) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'simple) in
    Obj.repr(
# 68 "parser.mly"
                                        ( makeExpr (Binop (_2, _1, _3)) )
# 389 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'simple) in
    Obj.repr(
# 69 "parser.mly"
                                        ( makeExpr (Binop (Eq, _1, _3)) )
# 397 "parser.ml"
               : 'expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'term) in
    Obj.repr(
# 72 "parser.mly"
                                        ( _1 )
# 404 "parser.ml"
               : 'simple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Keiko.op) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'term) in
    Obj.repr(
# 73 "parser.mly"
                                        ( makeExpr (Binop (_2, _1, _3)) )
# 413 "parser.ml"
               : 'simple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'simple) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'term) in
    Obj.repr(
# 74 "parser.mly"
                                        ( makeExpr (Binop (Minus, _1, _3)) )
# 421 "parser.ml"
               : 'simple))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'factor) in
    Obj.repr(
# 77 "parser.mly"
                                        ( _1 )
# 428 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'term) in
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Keiko.op) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'factor) in
    Obj.repr(
# 78 "parser.mly"
                                        ( makeExpr (Binop (_2, _1, _3)) )
# 437 "parser.ml"
               : 'term))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'variable) in
    Obj.repr(
# 81 "parser.mly"
                                        ( _1 )
# 444 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 82 "parser.mly"
                                        ( makeExpr (Constant (_1, Integer)) )
# 451 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 83 "parser.mly"
                                        ( makeExpr (Constant (_1, Boolean)) )
# 458 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Keiko.op) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'factor) in
    Obj.repr(
# 84 "parser.mly"
                                        ( makeExpr (Monop (_1, _2)) )
# 466 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'factor) in
    Obj.repr(
# 85 "parser.mly"
                                        ( makeExpr (Monop (Uminus, _2)) )
# 473 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 86 "parser.mly"
                                        ( _2 )
# 480 "parser.ml"
               : 'factor))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'name) in
    Obj.repr(
# 89 "parser.mly"
                                        ( makeExpr (Variable _1) )
# 487 "parser.ml"
               : 'variable))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'variable) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'expr) in
    Obj.repr(
# 90 "parser.mly"
                                        ( makeExpr (Sub (_1, _3)) )
# 495 "parser.ml"
               : 'variable))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Dict.ident) in
    Obj.repr(
# 93 "parser.mly"
                                        ( makeName _1 !Lexer.lineno )
# 502 "parser.ml"
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
