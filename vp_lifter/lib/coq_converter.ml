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
  let env = Global.env () in
  let sigma = Evd.from_env env in
  (* Create an identifier for the variable x *)
  let x_ident = Id.of_string "x" in
  (* let term = Constrexpr.String "Hello World!" in *)
  (* let term =
     Constrexpr.Number
       (NumTok.SPlus, NumTok.Unsigned.parse (Stream.of_string "5")) *)
  let term = Constr.mkInt (Uint63.of_int 5) in
  (* Declare the definition in the environment *)
  let definition_statement =
    Declarations.Def (x_ident, term)
    (* Opaque definition, set to true if you want to hide the definition *)
  in
  let _ =
    let open ModPath in
    let open DirPath in
    declare_definition ~poly:true x_ident sigma
  in
  (* Printer.env Format.std_formatter env *)
  ()
