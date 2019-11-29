(* lab3/main.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Print 
open Source

(* |main| -- main program *)
let main () =
  let dflag = ref false in
  let fns = ref [] in
  let usage =  "Usage: ppc [-d] file.p" in
  Arg.parse [("-d", Arg.Set dflag, " Print the tree");
      ("-O", Arg.Unit (fun () -> Kgen.optflag := true), " Peephole optimiser")]
    (function s -> fns := !fns @ [s]) usage;
  if List.length !fns <> 1 then begin 
    fprintf stderr "$\n" [fStr usage]; exit 2 
  end;
  let in_file = List.hd !fns in
  let in_chan = open_in in_file in
  Source.init in_file in_chan;
  let lexbuf = Lexing.from_channel in_chan in
  let prog = try Parser.program Lexer.token lexbuf with
      Parsing.Parse_error ->
        let tok = Lexing.lexeme lexbuf in
        err_message "syntax error at token '$'" 
          [fStr tok] !Lexer.lineno;
        exit 1 in

  if !dflag then Tree.print_tree stdout prog;

  begin try Check.annotate prog with
      Check.Semantic_error (fmt, args, line) ->
        err_message fmt args line;
        exit 1
  end;

  printf "MODULE Main 0 0\n" [];
  printf "IMPORT Lib 0\n" [];
  printf "ENDHDR\n\n" [];

  Kgen.translate prog;
  exit 0

let ppc = main ()
