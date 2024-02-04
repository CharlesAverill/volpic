open Lang.Read_tree
open Vp_lifter.Parse_tree
open Vp_lifter.Generator
open Vp_lifter.Converter
open Vp_lifter.String_utils
open Vp_lifter.Logging
open Argparse
open Filename

let get_parse_trees args =
  let dir = Sys.getcwd () in
  Sys.chdir (dirname args.input_fn) ;
  if args.do_compile then (
    let cmd =
      String.concat " "
        [args.fpc_path; "-vp"; args.fpc_flags; basename args.input_fn]
    in
    _log Log_Cmd cmd ;
    match Sys.command cmd with
    | 0 ->
        ()
    | n ->
        fatal rc_CompileError
          ( "Tree generation command `" ^ cmd ^ "` failed with exit code "
          ^ string_of_int n ) ) ;
  let parse_trees = read_tree args.tree_log args.use_preproc in
  Sys.chdir dir ; parse_trees

let () =
  let args = parse_arguments () in
  _log Log_Info "Parsing FPC Tree" ;
  let parse_trees = get_parse_trees args in
  let func_names =
    List.map
      (fun pt ->
        match pt.func_type with
        | Procedure (id, _) | Function (id, _, _) ->
            id
        | x ->
            fatal rc_ParseError
              ( "Expected procedure or function as root node, but got "
              ^ string_of_return_type_root x ) )
      parse_trees
  in
  let n_funcs = string_of_int (List.length func_names) in
  _log Log_Info "Converting to ASTs" ;
  let gasts_gammas_funcids =
    List.mapi
      (fun i (pt, func_name) ->
        _log Log_Info
          ( "Converting " ^ func_name ^ " (" ^ string_of_int i ^ "/" ^ n_funcs
          ^ ")" ) ;
        try gallina_of_parse_tree pt
        with Failure s ->
          let err = "Failed to convert " ^ func_name ^ ": " ^ s in
          _log Log_Error err ;
          (Comment err, fresh_gamma, []) )
      (List.combine parse_trees func_names)
  in
  _log Log_Info "Lifting ASTs to Coq" ;
  let out =
    String.concat "\n"
      ( List.mapi
          (fun i (func_name, (gast, gamma, ids)) ->
            _log Log_Info
              ( "Lifting " ^ func_name ^ " ("
              ^ string_of_int (i + 1)
              ^ "/" ^ n_funcs ^ ")" ) ;
            try
              string_of_gallina (i = 0) args.input_fn args.do_extract
                args.extract_language args.extract_path func_name gast gamma
            with Failure s ->
              let err = "Failed to lift " ^ func_name ^ ": " ^ s in
              _log Log_Error err ; comment err )
          (List.combine func_names gasts_gammas_funcids)
      @ ["Compute (main fresh_store)."] )
  in
  (* _log Log_Debug out ; *)
  let oc = open_out args.output_fn in
  Printf.fprintf oc "%s" out ; close_out oc
