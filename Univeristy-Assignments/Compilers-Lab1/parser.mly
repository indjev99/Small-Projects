/* lab1/parser.mly */
/* Copyright (c) 2017 J. M. Spivey */

%{ 
open Keiko
open Tree
%}

%token <Tree.ident>     IDENT
%token <Keiko.op>       MULOP ADDOP RELOP
%token <int>            NUMBER

/* punctuation and keywords */
%token                  SEMI DOT COLON LPAR RPAR COMMA
%token                  ASSIGN EOF BADTOK MINUS AND OR NOT
%token                  BEGIN END IF THEN ELSIF ELSE CASE OF VBAR
%token                  LOOP EXIT REPEAT UNTIL WHILE DO PRINT NEWLINE

%type <Tree.program>    program

%start                  program

%%

program :       
    BEGIN stmts END DOT                 { Program $2 } ;

stmts : 
    stmt_list                           { seq $1 } ;

stmt_list :
    stmt                                { [$1] }
  | stmt SEMI stmt_list                 { $1 :: $3 } ;

stmt :  
    /* empty */                         { Skip }
  | name ASSIGN expr                    { Assign ($1, $3) }
  | PRINT expr                          { Print $2 }
  | NEWLINE                             { Newline }
  | EXIT                                { ExitStmt }
  | IF expr THEN stmts iftail END       { IfStmt ($2, $4, $5) }
  | CASE expr OF initcase END           { CaseStmt ($2, $4) };
  | WHILE expr DO stmts whiletail END   { WhileStmt ($2, $4, $5) }
  | LOOP stmts END                      { LoopStmt ($2) }
  | REPEAT stmts UNTIL expr             { RepeatStmt ($2, $4) }

iftail :
    /* empty */                         { Skip }
  | ELSE stmts                          { $2 }
  | ELSIF expr THEN stmts iftail        { IfStmt ($2, $4, $5) };

initcase :
    /* empty */                         { None }
  | numlist COLON stmts casetail        { Match ($1, $3, $4) }
  | ELSE stmts                          { Default $2 }

casetail :
    /* empty */                         { None }
  | VBAR numlist COLON stmts casetail   { Match ($2, $4, $5) }
  | ELSE stmts                          { Default $2 }

whiletail :
    /* empty */                         { ExitStmt }
  | ELSE stmts                          { $2 }
  | ELSIF expr DO stmts whiletail       { IfStmt ($2, $4, $5) };

numlist :
    NUMBER                              { [$1] }
  | NUMBER COMMA numlist                { $1 :: $3 }

expr :
    orexpr                              { $1 }
  | IF expr THEN expr ifexprtail        { IfExpr ($2, $4, $5) } ;

ifexprtail :
    ELSE expr                           { $2 }
  | ELSIF expr THEN expr ifexprtail     { IfExpr ($2, $4, $5) } ;

orexpr :
    andexpr                             { $1 }
  | orexpr OR andexpr                  { Binop (Or, $1, $3) } ;

andexpr :
    notexpr                             { $1 }
  | andexpr OR notexpr                  { Binop (And, $1, $3) } ;

notexpr :
    cmpexpr                             { $1 }
  | NOT cmpexpr                         { Monop (Not, $2) } ;

cmpexpr :
    simple                              { $1 }
  | expr RELOP simple                   { Binop ($2, $1, $3) } ;
    
simple :
    term                                { $1 }
  | simple ADDOP term                   { Binop ($2, $1, $3) }
  | simple MINUS term                   { Binop (Minus, $1, $3) } ;

term :
    factor                              { $1 }
  | term MULOP factor                   { Binop ($2, $1, $3) } ;

factor :
    name                                { Variable $1 }
  | NUMBER                              { Constant $1 }
  | MINUS factor                        { Monop (Uminus, $2) }
  | LPAR expr RPAR                      { $2 } ;

name :
    IDENT                               { make_name $1 !Lexer.lineno } ;
