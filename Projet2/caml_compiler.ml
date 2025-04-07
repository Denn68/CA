(* from a 1986 paper: https://www.cs.tufts.edu/~nr/cs257/archive/dominique-clement/applicative.pdf *)

(* figure 1 page 14 (Abstract Syntax of Mini-ML) *)
type ident = string

type pat =
| PairPat of pat * pat
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
| Fun of pat * expr
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
and env = (pat * coms) list

and operator = Add | Sub | Mult

let rec addToEnv p coms (env : env) =
  match p with
  | NullPat -> []
  | IdentPat(x) -> [(x, coms)]
  | PairPat(p1, p2) ->
      let env1 = addToEnv p1 (Car :: coms) env in
      let env2 = addToEnv p2 (Cdr :: coms) env in
      env1 @ env2

let rec treePath (x : ident) p (coms : coms) =
  match p with
  | NullPat -> None
  | IdentPat(y) -> if x = y then Some coms else None
  | PairPat(p1, p2) ->
      match treePath x p1 (Car :: coms) with
      | Some path -> Some path
      | None -> treePath x p2 (Cdr :: coms)

let rec lookIntoEnv (x : ident) (env : env) : coms =
  match env with
  | [] -> failwith ("Unbound identifier: " ^ x)
  | p :: ps -> (
    let (p1, p2) = p in
      match treePath x p1 p2 with
      | Some path -> path
      | None -> Cdr :: lookIntoEnv x ps
  )
            


(* Figure 10 page 24 (Translation from Mini-ML to CAM) *)
let rec compile (env:env) (e:expr) : coms =
  match e with
  _ -> failwith "todo"
  | Number(n) -> [Quote(Int(n))]
  | True -> [Quote(Bool(true))]
  | False -> [Quote(Bool(false))]
  | Ident(i) -> lookIntoEnv i env
  | If(e1, e2, e3) -> [Push] @ compile env e1 @  [Branch((compile env e2) ,(compile env e3))]
  | Mlpair(e1, e2) -> [Push] @ compile env e1 @ [Swap] @ compile env e2 @ [Cons]
  | Fun(p,e) -> (
    let env2 = addToEnv p (compile env e) env in
    [Cur(compile env2 e)]
  )
  | Let(p, e1, e2) -> (
    let env2 = addToEnv p (compile env e1) env in
    [Push] @ compile env e1 @ [Cons] @ compile env2 e2
  )
  | LetRec(p, e1, e2) -> (
    let env2 = addToEnv p (compile env e1) env in
    [Push; Quote(env2); Cons; Push] @ compile env2 e1 @ [Swap; Rplac] @ compile env2 e2
  )
  | Apply(e1,e2) -> (
    let c1 = compile_trans e1 in
    match c1 with
    Car -> [(compile env e2); c1]
    | Cdr -> [(compile env e2); c1]
    | Op(_) -> [(compile env e2); c1]
    | _ -> [Push] @ compile env e1 @ [Swap] @ compile env e2 @ [Cons; App]
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
   