open MiniHDL_syntax

let clean_fsm ~rdy ~result (ts,s) typing_env =
  let vs_read = Hashtbl.create 200 in
  Hashtbl.add vs_read rdy ();
  Hashtbl.add vs_read result ();
  let rec collect_read_a = function
  | A_var x -> Hashtbl.add vs_read x ()
  | A_tuple aa -> List.iter collect_read_a aa
  | A_letIn(x,a1,a2) ->
      Hashtbl.add vs_read x ();
      collect_read_a a1;
      collect_read_a a2
  | (A_const _) -> ()
  | A_call(_,a) ->
     collect_read_a a
  | A_string_get(x,y) ->
     Hashtbl.add vs_read x ();
     Hashtbl.add vs_read y ()
  | A_array_get(x,y) ->
     Hashtbl.add vs_read x ();
     Hashtbl.add vs_read y ()
  | A_ptr_taken(x)
  | A_array_length(x,_)
  | A_encode(x,_,_)
  | A_decode(x,_) ->
      Hashtbl.add vs_read x ()
  | A_vector aa ->
      List.iter collect_read_a aa
  in

  let rec collect_s = function
  | S_skip -> ()
  | S_continue _ ->
      ()
  | S_if(x,s1,so) ->
      Hashtbl.add vs_read x ();
      collect_s s1;
      Option.iter collect_s so
  | S_case(x,hs,so) ->
      Hashtbl.add vs_read x ();
      List.iter (fun (_,s) -> collect_s s) hs;
      Option.iter collect_s so
  | S_set(x,a) ->
     collect_read_a a
  | S_acquire_lock _ | S_release_lock _ -> ()
  | S_read_start(_,a) ->
      collect_read_a a
  | S_read_stop _ ->
      ()
  | S_write_start(_,a,a_upd) ->
      collect_read_a a;
      collect_read_a a_upd
  | S_write_stop _ -> () 
  | S_array_set(x,y,a) ->
      Hashtbl.add vs_read x ();
      Hashtbl.add vs_read y ();
      collect_read_a a
  | S_seq(s1,s2) -> collect_s s1; collect_s s2
  | S_letIn(x,a,s) ->
      collect_read_a a;
      collect_s s
  | S_fsm(id,rdy,result,compute,ts,s) ->
      Hashtbl.add vs_read rdy ();
      Hashtbl.add vs_read result ();
      Hashtbl.add vs_read compute ();
      List.iter (fun (_,s) -> collect_s s) ts;
      collect_s s
  | S_in_fsm(id,s) ->
      collect_s s
  | S_call(op,a) ->
      collect_read_a a
  | S_external_run(_,_,_,_,a) ->
      collect_read_a a
  in
  List.iter (fun (_,s) -> collect_s s) ts;
  collect_s s;

  (* Hashtbl.iter (fun x _ -> if not @@ Hashtbl.mem vs_read x
                           then Printf.printf "%s assigned but never read\n" x) vs_assigned *)

  let vs_assigned_but_never_read = Hashtbl.create 200 in

  let rec clean s = match s with
  | S_skip
  | S_continue _ ->
      s
  | S_if(x,s1,so) ->
      S_if(x,clean s1,Option.map clean so)
  | S_case(x,hs,so) ->
      S_case(x, List.map (fun (c,s) -> c, clean s) hs,Option.map clean so)
  | S_set(x,_) -> (* caution with impure VHDL functions for simulation *)
     if not (Hashtbl.mem vs_read x) 
     then (Hashtbl.add vs_assigned_but_never_read x (); S_skip) 
     else s
  | S_acquire_lock _ 
  | S_release_lock _
  | S_write_start _
  | S_write_stop _
  | S_read_start _
  | S_read_stop _ 
  | S_array_set _ -> s
  | S_seq(s1,s2) -> S_seq(clean s1,clean s2)
  | S_letIn(x,a,s) ->
      S_letIn(x,a,clean s)
  | S_fsm(id,rdy,result,compute,ts,s) ->
      S_fsm(id,rdy,result,compute,List.map (fun (q,s) -> q, clean s) ts,clean s)
  | S_in_fsm(id,s) ->
      S_in_fsm(id,clean s)
  | S_call _ ->
      s
  | S_external_run _ -> s
  in
  let fsm' = (List.map (fun (q,s) -> q, clean s) ts, clean s) in
  Hashtbl.iter (fun x _ -> Hashtbl.remove typing_env x) vs_assigned_but_never_read;
  fsm'
