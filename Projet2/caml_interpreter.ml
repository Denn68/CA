open Caml_compiler

type value =
  | ValueInt of int
  | ValueBool of bool
  | ValueSymbol of string
  | ValuePair of value * value
  | ValueClosure of coms * value
  | Null

type stack = value list

type env = (value * value) list

let rec print_value v =
  match v with
  | ValueInt n -> Printf.printf " %d " n
  | ValueBool b -> Printf.printf " %b " b
  | ValueSymbol x -> Printf.printf " %s " x
  | ValuePair (v1, v2) ->
      Printf.printf " Pair(";
      print_value v1;
      Printf.printf ",";
      print_value v2;
      Printf.printf ") "
  | ValueClosure (c, v) ->
      Printf.printf " Closure (";
      Caml_compiler.print_coms c;
      Printf.printf " & ";
      print_value v;
      Printf.printf ") "
  | Null -> Printf.printf "Null"
  | _ -> Printf.printf "Unknown value"

let rec print_stack stack =
  match stack with
  | [] -> ()
  | v :: s -> 
      print_value v;
      Printf.printf " |\n ";
      print_stack s

let rec eval_com (stack : stack) (coms : coms) (env:env) : value =

  match coms with
  | [] -> (match stack with v :: _ -> v | [] -> failwith "Empty stack at end of program")
  | com :: cs -> (
      match com with

      | Quote (Int n) ->
          (match stack with
          | _ :: s -> eval_com (ValueInt n :: s) cs env
          | [] -> failwith "Quote on empty stack")

      | Quote (Bool b) ->
          (match stack with
          | _ :: s -> eval_com (ValueBool b :: s) cs env
          | [] -> failwith "Quote on empty stack")
          
      | Quote (Symbol x) ->
          (match stack with
          | _ :: s -> eval_com (ValueSymbol x :: s) cs env
          | [] -> failwith "Quote on empty stack")


      | Push -> (
          match stack with
          | v :: s -> eval_com (v :: v :: s) cs env
          | _ -> failwith "Push needs one value"
        )
      | Swap -> (
          match stack with
          | v1 :: v2 :: s -> eval_com (v2 :: v1 :: s) cs env
          | _ -> failwith "Swap needs two values"
        )
      | Cons -> (
          match stack with
          | v1 :: v2 :: s -> eval_com (ValuePair (v2, v1) :: s) cs env
          | _ -> failwith "Cons needs two values"
        )
      | Car -> (
          match stack with
          | ValuePair (a, _) :: s -> eval_com (a :: s) cs env
          | _ -> failwith "Car needs a pair"
        )
      | Cdr -> (
          match stack with
          | ValuePair (_, b) :: s -> eval_com (b :: s) cs env
          | _ -> failwith "Cdr needs a pair"
        )
      | Op op -> (
          match stack with
          | ValuePair (ValueInt a, ValueInt b) :: s ->
              let res =
                match op with
                | Add -> ValueInt (a + b)
                | Sub -> ValueInt (a - b)
                | Mult -> ValueInt (a * b)
                | Eq -> ValueBool (a = b)
              in
              eval_com (res :: s) cs env
          | _ -> failwith "Op needs a pair of integers"
        )
      | Branch (c1, c2) -> (
          match stack with
          | ValueBool true :: s -> eval_com s (c1 @ cs) env
          | ValueBool false :: s -> eval_com s (c2 @ cs) env
          | _ -> failwith "Branch needs a boolean"
        )
      | Cur c -> (
          match stack with
          | envrn :: s -> eval_com (ValueClosure (c, envrn) :: s) cs env
          | [] -> failwith "Cur needs an environment"
        )
      | App -> (
          match stack with
          | ValuePair (ValueClosure (c, closure_env), arg) :: s ->
              eval_com (ValuePair(closure_env,arg) :: s) (c @ cs) env

          | ValuePair (ValueSymbol sym, arg) :: s -> (
          let rec lookup sym env =
            match env with
            | (ValueSymbol k, v) :: _ when k = sym -> Some v
            | _ :: rest -> lookup sym rest
            | [] -> None
          in
          match lookup sym env with
          | Some (ValueClosure (c, closure_env)) ->
              eval_com (ValuePair(closure_env, arg) :: s) (c @ cs) env
          | Some _ -> failwith "Symbol does not map to a closure"
          | None -> failwith ("Unbound symbol: " ^ sym)
        )

          | _ -> failwith "App expects a pair (closure or symbol, arg)"
      )

      | Rplac -> (
          match stack with
          | ValuePair (rho, v) :: rho1 :: s ->
              let new_fun = (v, rho1) in
              let new_env = new_fun :: env in
              let new_pair = ValuePair (rho, rho1) in
              eval_com (new_pair :: s) cs new_env
          | _ -> failwith "Rplac needs a pair and an environment"
      )

    )

let eval_prog coms =
  let closure1 = ValueClosure ([Cdr; Op Add], Null) in
  let closure2 = ValueClosure ([Cdr; Op Sub], Null) in
  let pair1 = ValuePair (Null, closure1) in
  let pair2 = ValuePair (Null, closure2) in
  let init_value = ValuePair (pair1, pair2) in

  let stack = [init_value] in

  let env = [] in

  eval_com stack coms env



let () =
  let fname = Sys.argv.(1) in
  let ic = open_in fname in
  try
    let lexbuf = Lexing.from_channel ic in
    let e = Parser.prog Lexer.token lexbuf in
    let coms = Caml_compiler.compile_prog e in
    Caml_compiler.print_coms coms;
    Printf.printf "\n";
    let res = eval_prog coms in
    Printf.printf "Résultat : ";
    (match res with
    | ValueInt n -> Printf.printf "%d\n" n
    | ValueBool b -> Printf.printf "%b\n" b
    | ValueSymbol x -> Printf.printf "Symbole(%s)\n" x
    | ValuePair (_, _) -> Printf.printf "Pair\n"
    | ValueClosure _ -> Printf.printf "Closure\n"
    | Null -> Printf.printf "Null\n");
    close_in ic
  with
  | e ->
      Printf.eprintf "Erreur : %s\n" (Printexc.to_string e);
      close_in ic;
      raise e
