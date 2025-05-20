let () =
  let fname = Sys.argv.(1) in
  let ic = open_in fname in
  let lexbuf = Lexing.from_channel ic in
  try
    Printf.printf ">>> Début du lexing et parsing\n";

    (* Fonction de debug des tokens *)
    let rec debug_lexbuf () =
      let tok = Lexer.token lexbuf in
      Printf.printf "Token: %s\n"
        (match tok with
         | Parser.INT n -> Printf.sprintf "INT(%d)" n
         | Parser.IDENT s -> Printf.sprintf "IDENT(%s)" s
         | Parser.TRUE -> "TRUE"
         | Parser.FALSE -> "FALSE"
         | Parser.LET -> "LET"
         | Parser.REC -> "REC"
         | Parser.IN -> "IN"
         | Parser.IF -> "IF"
         | Parser.THEN -> "THEN"
         | Parser.ELSE -> "ELSE"
         | Parser.EQ -> "EQ"
         | Parser.FUN -> "FUN"
         | Parser.LPAREN -> "LPAREN"
         | Parser.RPAREN -> "RPAREN"
         | Parser.COMMA -> "COMMA"
         | Parser.RIGHT_ARROW -> "RIGHT_ARROW"
         | Parser.EOF -> "EOF");
      if tok <> Parser.EOF then debug_lexbuf ()
    in

    (* Afficher les tokens un par un (phase de débogage) *)
    debug_lexbuf ();

    (* Rewind *)
    seek_in ic 0;
    let lexbuf = Lexing.from_channel ic in

    Printf.printf "\n>>> Lancement du parsing\n";
    let ast = Parser.prog Lexer.token lexbuf in
    Printf.printf ">>> Parsing terminé avec succès\n";
    Printf.printf ">>> AST : %s\n" (Caml_compiler.string_of_expression ast);

    let coms = Caml_compiler.compile_prog ast in
    Caml_compiler.print_coms coms;
    Printf.printf "\n";

    close_in ic
  with
  | Parsing.Parse_error ->
      close_in ic;
      prerr_endline "Erreur pendant le parsing : Stdlib.Parsing.Parse_error"
  | Failure msg ->
      close_in ic;
      prerr_endline ("Erreur d'analyse lexicale ou autre : " ^ msg)
  | e ->
      close_in ic;
      raise e
