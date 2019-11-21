/* lab2/parser.mly */
/* Copyright (c) 2017 J. M. Spivey */

%{
open Keiko
open Dict 
open Tree
%}

%token <Dict.ident>     IDENT
%token <Keiko.op>       MULOP ADDOP RELOP MONOP
%token <int>            NUMBER BOOLCONST

/* punctuation */
%token                  SEMI DOT COLON LPAR RPAR COMMA
%token                  EQUAL MINUS ASSIGN EOF BADTOK
%token                  SUB BUS

/* keywords */
%token                  BEGIN DO ELSE END IF 
%token                  THEN VAR WHILE PRINT NEWLINE
%token                  ARRAY OF
%token                  INTEGER BOOLEAN

%type <Tree.program>    program

%start                  program

%%

program :       
    decls BEGIN stmts END DOT           { Program ($1, $3) } ;

decls : 
    /* empty */                         { [] }
  | decl decls                          { $1 :: $2 }

decl :
    VAR name_list COLON typexp SEMI     { Decl ($2, $4) } ;

name_list :     
    name                                { [$1] }
  | name COMMA name_list                { $1 :: $3 } ;

typexp :
    INTEGER                             { Integer }
  | BOOLEAN                             { Boolean } 
  | ARRAY NUMBER OF typexp              { Array ($2, $4) } ;

stmts : 
    stmt_list                           { seq $1 } ;

stmt_list :
    stmt                                { [$1] }
  | stmt SEMI stmt_list                 { $1 :: $3 } ;

stmt :  
    /* empty */                         { Skip }
  | variable ASSIGN expr                { Assign ($1, $3) }
  | PRINT expr                          { Print $2 }
  | NEWLINE                             { Newline }
  | IF expr THEN stmts END              { IfStmt ($2, $4, Skip) }
  | IF expr THEN stmts ELSE stmts END   { IfStmt ($2, $4, $6) }
  | WHILE expr DO stmts END             { WhileStmt ($2, $4) } ;

expr :
    simple                              { $1 }
  | expr RELOP simple                   { makeExpr (Binop ($2, $1, $3)) }
  | expr EQUAL simple                   { makeExpr (Binop (Eq, $1, $3)) } ;

simple :
    term                                { $1 }
  | simple ADDOP term                   { makeExpr (Binop ($2, $1, $3)) }
  | simple MINUS term                   { makeExpr (Binop (Minus, $1, $3)) } ;

term :
    factor                              { $1 }
  | term MULOP factor                   { makeExpr (Binop ($2, $1, $3)) }

factor :
    variable                            { $1 }
  | NUMBER                              { makeExpr (Constant ($1, Integer)) }
  | BOOLCONST                           { makeExpr (Constant ($1, Boolean)) }
  | MONOP factor                        { makeExpr (Monop ($1, $2)) }
  | MINUS factor                        { makeExpr (Monop (Uminus, $2)) }
  | LPAR expr RPAR                      { $2 } ;

variable :
    name                                { makeExpr (Variable $1) }
  | variable SUB expr BUS               { makeExpr (Sub ($1, $3)) } ;

name :  
    IDENT                               { makeName $1 !Lexer.lineno } ;
