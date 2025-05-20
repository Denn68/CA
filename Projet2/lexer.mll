{
  open Parser
}

let ident = ['a'-'z''_'] ['a'-'z''A'-'Z''0'-'9''_']*

rule token = parse
| (('-'?)['0'-'9']+) as lxm
                    { let n = int_of_string lxm in 
                      INT(n) }
| "true"             { TRUE }
| "false"            { FALSE }
| '('                { LPAREN }
| ')'                { RPAREN }
| ','                { COMMA }
| "let"              { LET }
| "fun"              { FUN }
| "rec"              { REC }
| "in"               { IN }
| "if"               { IF }
| "then"             { THEN }
| "else"             { ELSE }
| "="                { EQ }
| "->"               { RIGHT_ARROW }
| ['\n' ]            { (Lexing.new_line lexbuf); (token lexbuf) }
| [' ' '\t']         { token lexbuf }    (* skip blanks *)
| "(*"               { comment lexbuf }  (* Comment until closing *)
| ident as id        { IDENT(id) }
| "eof"              { EOF }             (* Change "eof" to a token EOF *)
| eof                { EOF }             (* This handles the end of the file *)
| _ as lxm           { failwith (Printf.sprintf "Unexpected character: %c" lxm) }

and comment = parse
| "*)"    { token lexbuf }
| ['\n']  { Lexing.new_line lexbuf; comment lexbuf }
| _       { comment lexbuf }
