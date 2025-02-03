open Ast

let intToBool i = if (i == 0) then false else true

let rec gen e =
  match e with
  | Add(left, right) -> eval left + eval right
  | Mul(left, right) -> eval left * eval right
  | Sub(left, right) -> eval left - eval right
  | Div(left, right) -> eval left / eval right
  | Integer(i) -> i
  | LessThan(left, right) -> if (eval left < eval right) then 1 else 0
  | Equal(left, right) -> if (eval left == eval right) then 1 else 0
  | GreaterThan(left, right) -> if(eval left > eval right) then 1 else 0
  | And(left, right) -> if(intToBool (eval left) && intToBool (eval right)) then 1 else 0
  | Or(left, right) -> if(intToBool (eval left) || intToBool (eval right)) then 1 else 0
  | Not(x) -> if(intToBool (eval x)) then 0 else 1
  | Boolean(x) -> x

let rec instr e =
  match e with
  | Print x ->
    match x with
      | [] -> Printf.printf "\n"
      | [Var(i)] -> Printf.printf "%s" i
      | e :: t -> Printf.printf "%d" (eval e); instr (Print (t))
      

