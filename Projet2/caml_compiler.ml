(* from a 1986 paper: https://www.cs.tufts.edu/~nr/cs257/archive/dominique-clement/applicative.pdf *)

module M = Map.Make(String)

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
and env = value M.t

and operator = Add | Sub | Mult

let rec addToEnv p v env =
  match p with
  NullPat -> env
  | IdentPat(p) -> M.add p v env
  | PairPat(p1,p2) -> (
    let (v1,v2) = v in
    let env1 = addToEnv p1 v1 env in
    addToEnv p2 v2 env1
  )

(* Figure 10 page 24 (Translation from Mini-ML to CAM) *)
let rec compile env (e:expr) : coms =
  match e with
  _ -> failwith "todo"
  | Number(n) -> Quote(n)
  | True -> Quote(Bool(True))
  | False -> Quote(Bool(False))
  | Ident(i) -> M.find i env
  | If(e1, e2, e3) -> [Push; compile env e1; Branch((compile env e2) (compile env e3)) ]
  | Mlpair(e1, e2) -> [Push; compile env e1; Swap; compile env e2; Cons]
  | Fun(p,e) -> (
    let env2 = addToEnv p (compile env e) env in
    Cur(compile env2 e)
  )
  | Let(p, e1, e2) -> (
    let env2 = addToEnv p (compile env e1) env in
    [Push; compile env e1; Cons; compile env2 e2]
  )
  | LetRec(p, e1, e2) -> (
    let env2 = addToEnv p (compile env e1) env in
    [Push; Quote(env2); Cons; Push; compile env2 e1; Swap; Rplac; compile env2 e2]
  )
  | Apply(e1,e2) -> (
    let c1 = compile_trans e1 in
    match c1 with
    Car -> [(compile env e2); c1]
    | Cdr -> [(compile env e2); c1]
    | Op(_) -> [(compile env e2); c1]
    | _ -> [Push; compile env e1; Swap; compile env e2; Cons; App]
  )
and compile_trans e =
  match e with
  Ident("fst") -> Car
  | Ident("and") -> Cdr
  | Ident(x) -> 
    match x with
    "add" -> Op(Add)
    | "sub" -> Op(Sub)
    | "mult" -> Op(Mult)
   