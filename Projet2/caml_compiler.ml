(* from a 1986 paper: https://www.cs.tufts.edu/~nr/cs257/archive/dominique-clement/applicative.pdf *)

(* figure 1 page 14 (Abstract Syntax of Mini-ML) *)
type ident = string

type pat =
| PairPat of pat * pat
| IdentPat of ident
| NullPat

type expression =
| Ident of ident
| Number of int
| False
| True
| Apply of expression * expression
| Mlpair of expression * expression
| Lambda of pat * expression
| Fun of pat * expression
| Let of pat * expression * expression
| LetRec of pat * expression * expression
| If of expression * expression * expression


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
| Symbol of string   (* ajout *)
and env = pat

and operator = Add | Sub | Mult | Eq

let print_coms (coms : coms) =
  let rec aux coms =
    match coms with
    | [] -> ()
    | [c] -> print_com c  (* dernier élément, pas de virgule après *)
    | c :: cs ->
        print_com c;
        Printf.printf ", ";
        aux cs
  and print_com c =
    match c with
    | Quote v ->
        (match v with
        | Int n -> Printf.printf "Quote(Int(%d))" n
        | Bool b -> Printf.printf "Quote(Bool(%b))" b
        | NullValue -> Printf.printf "NullValue"
        | Symbol s -> Printf.printf "Quote(Symbol(%s))" s)
    | Op o ->
        (match o with
        | Add -> Printf.printf "Add"
        | Sub -> Printf.printf "Sub"
        | Mult -> Printf.printf "Mult"
        | Eq -> Printf.printf "Eq")
    | Car -> Printf.printf "Car"
    | Cdr -> Printf.printf "Cdr"
    | Cons -> Printf.printf "Cons"
    | Push -> Printf.printf "Push"
    | Swap -> Printf.printf "Swap"
    | App -> Printf.printf "App"
    | Rplac -> Printf.printf "Rplac"
    | Cur c ->
        Printf.printf "Cur([";
        aux c;
        Printf.printf "])"
    | Branch (c1, c2) ->
        Printf.printf "Branch([";
        aux c1;
        Printf.printf "], [";
        aux c2;
        Printf.printf "])"
  in
  Printf.printf "[";
  aux coms;
  Printf.printf "]"


let rec string_of_expression expr =
  match expr with
  | Ident s -> Printf.sprintf "Ident(\"%s\")" s
  | Number n -> Printf.sprintf "Number(%d)" n
  | True -> "True"
  | False -> "False"
  | Fun (pat, e) ->
      Printf.sprintf "Fun(%s, %s)" (string_of_pat pat) (string_of_expression e)
  | Let (pat, e1, e2) ->
      Printf.sprintf "Let(%s, %s, %s)" (string_of_pat pat) (string_of_expression e1) (string_of_expression e2)
  | LetRec (pat, e1, e2) ->
      Printf.sprintf "LetRec(%s, %s, %s)" (string_of_pat pat) (string_of_expression e1) (string_of_expression e2)
  | If (e1, e2, e3) ->
      Printf.sprintf "If(%s, %s, %s)" (string_of_expression e1) (string_of_expression e2) (string_of_expression e3)
  | Apply (e1, e2) ->
      Printf.sprintf "Apply(%s, %s)" (string_of_expression e1) (string_of_expression e2)
  | Mlpair (e1, e2) ->
      Printf.sprintf "MlPair(%s, %s)" (string_of_expression e1) (string_of_expression e2)

and string_of_pat pat =
  match pat with
  | IdentPat s -> Printf.sprintf "IdentPat(\"%s\")" s
  | NullPat -> "NullPat"
  | PairPat (p1, p2) ->
      Printf.sprintf "PairPat(%s, %s)" (string_of_pat p1) (string_of_pat p2)



(* Figure 9 page 23 (Environment) *)

let rec treePath (x : ident) (p : pat) : coms option =
  match p with
  | NullPat -> None
  | IdentPat y ->
      if x = y then Some [] else None
  | PairPat(p1, p2) ->
      match treePath x p1 with
      | Some path -> Some (Car :: path)
      | None ->
          match treePath x p2 with
          | Some path -> Some (Cdr :: path)
          | None -> None


let lookIntoEnv (x : ident) (env : pat) : coms =
  match treePath x env with
  | Some path -> path
  | None -> failwith ("Unbound identifier: " ^ x)


            
let counter = ref 0
let fresh () =
  let n = !counter in
  incr counter;
  "_rec" ^ string_of_int n


(* Figure 10 page 24 (Translation from Mini-ML to CAM) *)
let rec compile (env:env) (e:expression) : coms =
  match e with

  Number(n) -> [Quote(Int(n))]

  | True -> [Quote(Bool(true))]

  | False -> [Quote(Bool(false))]

  | Ident(i) ->
    lookIntoEnv i env

  | If(e1, e2, e3) -> [Push] @ compile env e1 @  [Branch((compile env e2) ,(compile env e3))]

  | Mlpair(e1, e2) -> [Push] @ compile env e1 @ [Swap] @ compile env e2 @ [Cons]

  | Fun(p,e) -> (
    let body = compile (PairPat(env,p)) e in
    [Cur(body)]
  )

  | Let(p, e1, e2) -> (
    let env2 = PairPat(env,p) in
    [Push] @ compile env e1 @ [Cons] @ compile env2 e2
  )

  | LetRec(p, e1, e2) -> (
    let p1 = fresh () in
    let env2 = PairPat(env,p) in
    let c1 = compile env2 e1 in
    let c2 = compile env2 e2 in
    [Push; Quote(Symbol p1); Cons; Push] @ c1 @ [Swap; Rplac] @ c2
  )

  | Apply(e1,e2) -> (
    match e1 with
    | Ident("fst") | Ident("snd") | Ident("add") | Ident("sub") | Ident("mult") | Ident("eq")->
        let c1 = compile_trans e1 in
        compile env e2 @ [c1]
    | _ ->
        [Push] @ compile env e1 @ [Swap] @ compile env e2 @ [Cons; App]
  )
  | _ -> failwith "todo"
and compile_trans e =
  match e with
  | Ident("fst") -> Car
  | Ident("snd") -> Cdr
  | Ident("add") -> Op(Add)
  | Ident("sub") -> Op(Sub)
  | Ident("mult") -> Op(Mult)
  | Ident("eq") -> Op(Eq)
;;


let compile_prog (e:expression) : coms =
  let env = NullPat in
  compile env e
;;
