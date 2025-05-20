open Caml_compiler

type flat_com =
  | FQuote of value
  | FPush
  | FSwap
  | FCons
  | FCar
  | FCdr
  | FOp of operator
  | FBranch of int * int
  | FCur of int
  | FApp
  | FRplac

let string_of_op = function
  | Add -> "Add"
  | Sub -> "Sub"
  | Mult -> "Mult"
  | Eq -> "Eq"

let string_of_flat_com = function
  | FQuote n -> 
      (match n with
       | Int i -> Printf.sprintf "Quote(Int(%d))" i
       | Bool b -> Printf.sprintf "Quote(Bool(%b))" b
       | NullValue -> "NullValue"
       | Symbol s -> Printf.sprintf "Quote(Symbol(%s))" s)
  | FPush -> "Push"
  | FSwap -> "Swap"
  | FCons -> "Cons"
  | FCar -> "Car"
  | FCdr -> "Cdr"
  | FOp op -> string_of_op op
  | FBranch (i1, i2) -> Printf.sprintf "Branch(%d,%d)" i1 i2
  | FCur i -> Printf.sprintf "Cur(%d)" i
  | FApp -> "App"
  | FRplac -> "Rplac"

let flatten (prog : com list) : flat_com list =
  let counter = ref 0 in
  let code = ref [] in

  let rec flatten_com (c : com) : unit =
    match c with
    | Quote v ->
        code := !code @ [FQuote v]; incr counter
    | Push ->
        code := !code @ [FPush]; incr counter
    | Swap ->
        code := !code @ [FSwap]; incr counter
    | Cons ->
        code := !code @ [FCons]; incr counter
    | Car ->
        code := !code @ [FCar]; incr counter
    | Cdr ->
        code := !code @ [FCdr]; incr counter
    | Op op ->
        code := !code @ [FOp op]; incr counter
    | App ->
        code := !code @ [FApp]; incr counter
    | Rplac ->
        code := !code @ [FRplac]; incr counter
    | Cur body ->
        let start = !counter in
        ignore (flatten_list body);
        code := !code @ [FCur start];
        incr counter
    | Branch (c1, c2) ->
        let i1 = !counter in
        ignore (flatten_list c1);
        let i2 = !counter in
        ignore (flatten_list c2);
        code := !code @ [FBranch(i1, i2)];
        incr counter

  and flatten_list (lst : com list) : unit =
    List.iter flatten_com lst
  in

  flatten_list prog;
  !code

let generate_eclat_code (flat_code : flat_com list) : unit =
  let oc = open_out "code.ecl" in
  Printf.fprintf oc "let code = create<1024>() ;;\n\n";
  Printf.fprintf oc "let load_code() =\n";
  List.iteri (fun i c ->
    Printf.fprintf oc "  set(code, %d, %s);" i (string_of_flat_com c)
  ) flat_code;
  Printf.fprintf oc ";\n";
  close_out oc

let () =
  let fname = Sys.argv.(1) in
  let ic = open_in fname in
  try
    let lexbuf = Lexing.from_channel ic in
    Printf.printf "Lexing OK\n";
    let e = Parser.prog Lexer.token lexbuf in
    Printf.printf "Parser OK\n";
    let coms = Caml_compiler.compile_prog e in
    Caml_compiler.print_coms coms;
    Printf.printf "\n";
    close_in ic;
    let flat_code = flatten coms in
    generate_eclat_code flat_code;
  with
  | e ->
    Printf.eprintf "Erreur pendant le parsing : %s\n" (Printexc.to_string e);
    close_in ic;
    raise e