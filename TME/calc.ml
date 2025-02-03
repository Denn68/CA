let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.calc Lexer.token lexbuf in
  let result = Eval.instr ast in
  result; print_newline(); flush stdout
