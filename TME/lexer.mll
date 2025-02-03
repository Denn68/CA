{
  open Parser
}

let integer = '-'?['0'-'9']+
let var = ['a'-'z']['a'-'z''A'-'Z''0'-'9']*
let spaces = [' ' '\t']
let boolean = "1" | "0"
let eol = '\n'
let com = ['R']['E']['M'][^'\n']* '\n'

rule token = parse
    spaces        { token lexbuf }
  | "+"           { PLUS }
  | "*"           { MUL }
  | "-"           { MINUS }
  | "/"           { DIV }
  | "<"           { LT }
  | "="           { EQ }
  | ">"           { GT }
  | "!"           { NOT }
  | "AND"         { AND }
  | "OR"          { OR }
  | "("           { LPAREN }
  | ")"           { RPAREN }
  | "PRINT"	      { PRINT }
  | ";"           { COMMA }
  | integer as x  { INTEGER(int_of_string x) }
  | var as x      { VAR(x) }
  | boolean as x  { BOOLEAN(int_of_char x) }
  | eol           { EOL }
  | com           { token lexbuf }

(*
     | PLUS expr            { $2 }
     | MINUS expr           { Sub(0, $2) }
     *)