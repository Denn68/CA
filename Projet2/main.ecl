let code = create<1024>() ;;

type op =
  Add of unit
  | Sub of unit
  | Mult of unit
  | Eq of unit;;

type value =
  Int of int
  | Bool of bool
  | NullValue of unit
  | Pair of (value * value)
  | Quote of int
  | Symbol of string
  | Closure of int
  | Push of unit
  | Swap of unit
  | Cons of unit
  | Cur of int * int
  | Car of unit
  | Cdr of unit
  | Op of op
  | Branch of int * int
  | Rplac of unit
  | App of unit
  | Jump of int;;

let load_code() =
  set(code, 0, Push ());
  set(code, 1, Quote(3));
  set(code, 2, Cons ());
  set(code, 3, Cdr ());;

let rec run_interpr (pc, ps, stack) =
  let instr = get(code, pc) in

  match instr with

  Quote v ->
    set(stack, ps, v);
    run_interpr (pc + 1, ps + 1, stack)

  | Push () ->
    let v = get(stack, ps) in
    set(stack, ps + 1, v);
    run_interpr (pc + 1, ps + 1, stack)

  | Swap () ->
    let v1 = get(stack, ps) in
    let v2 = get(stack, ps - 1) in
    set(stack, ps, v2);
    set(stack, ps - 1, v1);
    run_interpr (pc + 1, ps, stack)

  | Cons () ->
    let v1 = get(stack, ps) in
    let v2 = get(stack, ps - 1) in
    set(stack, ps - 1, Pair (v2, v1));
    run_interpr (pc + 1, ps - 1, stack)

  | Car () ->
    let p = get(stack, ps - 1) in
    (match p with
      | Pair (a, _) -> set(stack, ps - 1, a); run_interpr (pc + 1, ps - 1, stack))

  | Cdr () ->
    let p = get(stack, ps - 1) in
    (match p with
      | Pair (_, b) -> set(stack, ps - 1, b); run_interpr (pc + 1, ps - 1, stack))

  | Op op ->
    let v1 = get(stack, ps) in
    let v2 = get(stack, ps - 1) in
    (match v1 with
      | Int i1 ->
        (match v2 with
          | Int i2 ->
            let res = match op with
              | Add () -> i1 + i2
              | Sub () -> i1 - i2
              | Mult () -> i1 * i2
              | Eq () -> if i1 = i2 then 1 else 0
            in
            set(stack, ps - 1, Int res);
            run_interpr (pc + 1, ps - 1, stack)
        )
    )

  | Cur (d,f) ->
    set(stack, ps, Closure d);
    run_interpr (f, ps, stack)

  | Jump i ->
    run_interpr (i, ps, stack)

  | App () -> run_interpr (pc + 1, ps - 1, stack)
  
  | Rplac () -> run_interpr (pc + 1, ps, stack)

  | Branch (i1, i2) ->
    let cond = get(stack, ps - 1) in
    if cond = 0 then
      run_interpr (i1, ps - 1, stack)
    else
      run_interpr (i2, ps - 1, stack)
;;

let counter() =
  reg (fun c -> c + 1) init 0 ;;

let main (bouton : bool) =
  let cy = counter () in
  let (v, rdy) = exec

        load_code();

        print_string "start execution at "; print_int cy;
        print_string "!"; print_newline ();

        let stack = create<1024>() in
        run_interpr (0, 0, stack);

        print_string "execution is finished at "; print_int cy;
        print_string "!"; print_newline ();

        42

        default 0
  in
  let green_led = not(rdy) in
  green_led ;;