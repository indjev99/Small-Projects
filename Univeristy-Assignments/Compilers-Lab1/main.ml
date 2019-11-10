(* lab1/main.ml *)
(* Copyright (c) 2017 J. M. Spivey *)

open Print

(* |main| -- main program *)
let main () =
  let dflag = ref 0 in
  let fns = ref [] in
  let usage =  "Usage: ppc [-d] file.p" in
  Arg.parse 
    [("-d", Arg.Unit (fun () -> incr dflag), " Print the tree for debugging");
      ("-O", Arg.Unit (fun () -> Kgen.optflag := true), " Peephole optimiser")]
    (function s -> fns := !fns @ [s]) usage;
  if List.length !fns <> 1 then begin 
    fprintf stderr "$\n" [fStr usage]; exit 2 
  end;

  let in_file = List.hd !fns in
  let in_chan = open_in in_file in
  Source.init in_file in_chan;
  ignore (Parsing.set_trace (!dflag > 1));
  let lexbuf = Lexing.from_channel in_chan in
  let prog = try Parser.program Lexer.token lexbuf with
      Parsing.Parse_error ->
        let tok = Lexing.lexeme lexbuf in
        Source.err_message "syntax error at token '$'" 
          [fStr tok] !Lexer.lineno;
        exit 1 in

  if !dflag > 0 then Tree.print_tree stdout prog;

  printf "MODULE Main 0 0\n" [];
  printf "IMPORT Lib 0\n" [];
  printf "ENDHDR\n\n" [];

  printf "PROC MAIN 0 0 0\n" [];
  Kgen.translate prog;
  printf "RETURN\n" [];
  printf "END\n\n" [];

  List.iter 
    (fun x -> printf "GLOVAR _$ 4\n" [fStr x]) 
    (Lexer.get_vars ());

  exit 0

let ppc = main ()
