(* from a 1986 paper: https://www.cs.tufts.edu/~nr/cs257/archive/dominique-clement/applicative.pdf *)

(* figure 1 page 14 (Abstract Syntax of Mini-ML) *)
type ident = string

type pat =
| Pairpat of pat * pat
| IdentPat of ident
| NullPat

type expr =
| Ident of ident
| Number of int
| False
| True
| Apply of expr * expr
| Mlpair of expr * expr
| Lambda of pat * expr
| Let of pat * expr * expr
| LetRec of pat * expr * expr
| If of expr * expr * expr


(* figure 7 page 21 (Abstract syntax of CAM code) *)

type program = coms
and coms = com list
and com =
| Quote of value
| Op of operator
| Car
| Cdr
| Cons
| Push
| Swap
| App
| Rplac
| Cur of coms
| Branch of coms * coms
and value =
| Int of int
| Bool of bool
| NullValue

and operator = Add | Sub | Mult

(* Figure 10 page 24 (Translation from Mini-ML to CAM) *)
let rec compile env (e:expr) : coms =
  match e with
  | _ -> failwith "todo"
  | Number(n) -> Quote(n)
  | True -> Quote(Bool(True))
  | False -> Quote(Bool(False))
  | Ident(i) ->
  | If(e1, e2, e3) -> [Push; compile env e1; Branch((compile env e2) (compile env e3)) ]
  | Mlpair(e1, e2) -> [Push; compile env e1; Swap; compile env e2; Cons]
  | Let(p, e1, e2) -> [Push; compile env e1; Cons; compile env e2]
  | LetRec(p, e1, e2) -> [Push]