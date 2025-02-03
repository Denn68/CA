type token =
  | MUL
  | DIV
  | PLUS
  | MINUS
  | LT
  | EQ
  | GT
  | AND
  | OR
  | NOT
  | LPAREN
  | RPAREN
  | COMMA
  | EOL
  | PRINT
  | INTEGER of (int)
  | VAR of (string)
  | BOOLEAN of (int)

val calc :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Ast.inst
