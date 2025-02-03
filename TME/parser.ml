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

open Parsing;;
let _ = parse_error;;
# 2 "parser.mly"
open Ast
# 26 "parser.ml"
let yytransl_const = [|
  257 (* MUL *);
  258 (* DIV *);
  259 (* PLUS *);
  260 (* MINUS *);
  261 (* LT *);
  262 (* EQ *);
  263 (* GT *);
  264 (* AND *);
  265 (* OR *);
  266 (* NOT *);
  267 (* LPAREN *);
  268 (* RPAREN *);
  269 (* COMMA *);
  270 (* EOL *);
  271 (* PRINT *);
    0|]

let yytransl_block = [|
  272 (* INTEGER *);
  273 (* VAR *);
  274 (* BOOLEAN *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
\002\000\002\000\002\000\002\000\005\000\006\000\006\000\003\000\
\003\000\003\000\004\000\004\000\004\000\004\000\000\000"

let yylen = "\002\000\
\002\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
\002\000\001\000\001\000\001\000\002\000\002\000\003\000\003\000\
\003\000\001\000\001\000\001\000\001\000\003\000\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\023\000\000\000\000\000\000\000\019\000\
\000\000\000\000\000\000\000\000\018\000\013\000\001\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\022\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\015\000\020\000\021\000\000\000\000\000"

let yydgoto = "\002\000\
\004\000\011\000\012\000\013\000\005\000\014\000"

let yysindex = "\084\000\
\074\255\000\000\076\255\000\000\077\255\076\255\076\255\000\000\
\000\000\000\000\075\255\008\255\000\000\000\000\000\000\095\255\
\255\254\076\255\076\255\076\255\076\255\076\255\076\255\076\255\
\076\255\079\255\079\255\000\000\095\255\095\255\095\255\095\255\
\095\255\095\255\095\255\000\000\000\000\000\000\008\255\008\255"

let yyrindex = "\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\018\255\031\255\000\000\042\255\000\000\000\000\000\000\016\255\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\100\255\000\000\000\000\000\000\029\255\040\255\051\255\062\255\
\093\255\096\255\098\255\000\000\000\000\000\000\053\255\064\255"

let yygindex = "\000\000\
\000\000\250\255\086\000\000\000\000\000\082\000"

let yytablesize = 114
let yytable = "\016\000\
\017\000\018\000\019\000\020\000\021\000\022\000\023\000\024\000\
\026\000\027\000\028\000\029\000\030\000\031\000\032\000\033\000\
\034\000\035\000\020\000\020\000\010\000\010\000\010\000\010\000\
\010\000\010\000\010\000\009\000\009\000\010\000\010\000\021\000\
\021\000\011\000\011\000\011\000\011\000\011\000\011\000\011\000\
\002\000\002\000\011\000\011\000\012\000\012\000\012\000\012\000\
\012\000\012\000\012\000\003\000\003\000\012\000\012\000\016\000\
\016\000\016\000\016\000\016\000\016\000\016\000\004\000\004\000\
\016\000\016\000\017\000\017\000\017\000\017\000\017\000\017\000\
\017\000\005\000\005\000\017\000\017\000\018\000\019\000\020\000\
\021\000\022\000\023\000\024\000\001\000\006\000\007\000\025\000\
\003\000\007\000\015\000\008\000\009\000\010\000\008\000\037\000\
\038\000\018\000\019\000\020\000\021\000\022\000\023\000\024\000\
\006\000\006\000\036\000\007\000\007\000\008\000\008\000\039\000\
\040\000\014\000"

let yycheck = "\006\000\
\007\000\003\001\004\001\005\001\006\001\007\001\008\001\009\001\
\001\001\002\001\012\001\018\000\019\000\020\000\021\000\022\000\
\023\000\024\000\001\001\002\001\003\001\004\001\005\001\006\001\
\007\001\008\001\009\001\012\001\013\001\012\001\013\001\001\001\
\002\001\003\001\004\001\005\001\006\001\007\001\008\001\009\001\
\012\001\013\001\012\001\013\001\003\001\004\001\005\001\006\001\
\007\001\008\001\009\001\012\001\013\001\012\001\013\001\003\001\
\004\001\005\001\006\001\007\001\008\001\009\001\012\001\013\001\
\012\001\013\001\003\001\004\001\005\001\006\001\007\001\008\001\
\009\001\012\001\013\001\012\001\013\001\003\001\004\001\005\001\
\006\001\007\001\008\001\009\001\001\000\010\001\011\001\013\001\
\015\001\011\001\014\001\016\001\017\001\018\001\016\001\017\001\
\018\001\003\001\004\001\005\001\006\001\007\001\008\001\009\001\
\012\001\013\001\025\000\012\001\013\001\012\001\013\001\026\000\
\027\000\014\001"

let yynames_const = "\
  MUL\000\
  DIV\000\
  PLUS\000\
  MINUS\000\
  LT\000\
  EQ\000\
  GT\000\
  AND\000\
  OR\000\
  NOT\000\
  LPAREN\000\
  RPAREN\000\
  COMMA\000\
  EOL\000\
  PRINT\000\
  "

let yynames_block = "\
  INTEGER\000\
  VAR\000\
  BOOLEAN\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Ast.inst) in
    Obj.repr(
# 19 "parser.mly"
                               ( _1 )
# 154 "parser.ml"
               : Ast.inst))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 21 "parser.mly"
                            ( Add(_1, _3) )
# 162 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 22 "parser.mly"
                            ( Sub(_1, _3) )
# 170 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 23 "parser.mly"
                            ( LessThan(_1, _3) )
# 178 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 24 "parser.mly"
                            ( Equal(_1, _3) )
# 186 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 25 "parser.mly"
                            ( GreaterThan(_1, _3) )
# 194 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 26 "parser.mly"
                            ( And(_1, _3) )
# 202 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 27 "parser.mly"
                            ( Or(_1, _3) )
# 210 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 28 "parser.mly"
                            ( Not(_2) )
# 217 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 29 "parser.mly"
                            ( Var(_1) )
# 224 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 30 "parser.mly"
                            ( Boolean(_1) )
# 231 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 31 "parser.mly"
                            ( _1 )
# 238 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'exprs) in
    Obj.repr(
# 33 "parser.mly"
                       (Print(_2))
# 245 "parser.ml"
               : Ast.inst))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : Ast.expr) in
    Obj.repr(
# 36 "parser.mly"
                          ([_1])
# 252 "parser.ml"
               : 'exprs))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'exprs) in
    Obj.repr(
# 37 "parser.mly"
                          (_1::_3)
# 260 "parser.ml"
               : 'exprs))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 40 "parser.mly"
                            ( Mul(_1, _3) )
# 268 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : Ast.expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 41 "parser.mly"
                            ( Div(_1, _3) )
# 276 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : Ast.expr) in
    Obj.repr(
# 42 "parser.mly"
                            ( _1 )
# 283 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 44 "parser.mly"
                            ( Integer(_1) )
# 290 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 45 "parser.mly"
                            ( Var(_1))
# 297 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 46 "parser.mly"
                            ( Boolean(_1))
# 304 "parser.ml"
               : Ast.expr))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : Ast.expr) in
    Obj.repr(
# 47 "parser.mly"
                            ( _2 )
# 311 "parser.ml"
               : Ast.expr))
(* Entry calc *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let calc (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.inst)
;;
