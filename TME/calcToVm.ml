let _ =
  let oc = open_out "bytecode.txt" in 
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.calc Lexer.token lexbuf in
  let result = Gen.gen ast in
  output_string oc result; 
  close_out oc;