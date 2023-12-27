let string_of_gallina _ = ""

open Names
open Term

let init_coq () =
  let args, () =
    Coqinit.parse_arguments
      ~parse_extra:(fun _ -> ((), []))
      ~usage:
        Boot.Usage.
          {executable_name= "vp_lifter"; extra_args= ""; extra_options= ""}
      ()
  in
  let cmds = Coqinit.init_runtime args in
  Coqinit.start_library ~top:Names.DirPath.initial cmds

let declare_definition ~poly name sigma body =
  let cinfo = Declare.CInfo.make ~name ~typ:None () in
  let info = Declare.Info.make ~poly () in
  Declare.declare_definition ~info ~cinfo ~opaque:false ~body sigma

let simple_body_access gref =
  let open Names.GlobRef in
  match gref with
  | VarRef _ ->
      failwith "variables are not covered in this example"
  | IndRef _ ->
      failwith "inductive types are not covered in this example"
  | ConstructRef _ ->
      failwith "constructors are not covered in this example"
  | ConstRef cst -> (
      let cb = Environ.lookup_constant cst (Global.env ()) in
      match Global.body_of_constant_body Library.indirect_accessor cb with
      | Some (e, _, _) ->
          EConstr.of_constr e
      | None ->
          failwith "This term has no value" )

let converter_test () =
  init_coq () ;
  (* Create an environment for the definition *)
  let env = Global.env () in
  let sigma = Evd.from_env env in
  (* Create an identifier for the variable x *)
  let x_ident = Id.of_string "x" in
  (* let term = Constrexpr.String "Hello World!" in *)
  let term =
    Constrexpr.Number
      (NumTok.SPlus, NumTok.Unsigned.parse (Stream.of_string "5"))
  in
  (* let term = Constrintern.interp_constr_evars env sigma (CAst.make (Constrexpr.String "Hello World!")) in *)
  (* Declare the definition in the environment *)
  (* let invProof, sigma = inversion_scheme ~name ~poly env sigma t sort dep inv_op in *)
  let poly = true in
  let sigma, t =
    Constrintern.interp_constr_evars env sigma
      (CAst.make (Constrexpr.CPrim term))
  in
  let five_ref = declare_definition ~poly x_ident sigma t in
  (* Print the environment to see the effect *)
  (* Printenv.summary Format.std_formatter env *)
  (* print_endline (Pp.db_string_of_pp (Printer.pr_rel_context_of env sigma)) *)
  let print r =
    Pp.app (Pp.strbrk "Defined ") (Pp.app (Printer.pr_global r) (Pp.strbrk "."))
  in
  print_endline (Pp.db_string_of_pp (print five_ref)) ;
  try
    let t =
      simple_body_access (Nametab.global (Libnames.qualid_of_string "x"))
    in
    Feedback.msg_notice (Printer.pr_econstr_env env sigma t) ;
    print_endline (Pp.db_string_of_pp (Printer.pr_econstr_env env sigma t))
  with Failure s -> CErrors.user_err (Pp.str s)
