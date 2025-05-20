let () =
  let fname = Sys.argv.(1) in
  let ic = open_in fname in
  try
    let lexbuf = Lexing.from_channel ic in
    Printf.printf "Lexing OK\n";
    let e = Parser.prog Lexer.token lexbuf in
    Printf.printf "Parser OK\n";
    let coms = Caml_compiler.compile_prog e in
    Caml_compiler.print_coms coms;
    Printf.printf "\n";
    close_in ic
  with
  | e ->
    Printf.eprintf "Erreur pendant le parsing : %s\n" (Printexc.to_string e);
    close_in ic;
    raise e
