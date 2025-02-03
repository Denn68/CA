type expr =
  | Add of expr * expr
  | Mul of expr * expr
  | Sub of expr * expr
  | Div of expr * expr
  | LessThan of expr * expr
  | Equal of expr * expr
  | GreaterThan of expr * expr
  | And of expr * expr
  | Or of expr * expr
  | Not of expr
  | Integer of int
  | Var of string
  | Boolean of int
  
type inst =
  | Print of expr list
