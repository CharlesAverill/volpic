open Lang.Read_tree
open Vp_lifter.Parse_tree
open Vp_lifter.Generator
open Vp_lifter.Converter
open Vp_lifter.String_utils
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
    print_endline cmd ;
    match Sys.command cmd with
    | 0 ->
        ()
    | n ->
        failwith
          ( "Tree generation command `" ^ cmd ^ "` failed with exit code "
          ^ string_of_int n ) ) ;
  let parse_trees = read_tree args.tree_log args.use_preproc in
  Sys.chdir dir ; parse_trees

let () =
  let args = parse_arguments () in
  print_endline "Parsing..." ;
  let parse_trees = get_parse_trees args in
  let func_names =
    List.map
      (fun pt ->
        match pt.func_type with
        | Procedure (id, _) | Function (id, _, _) ->
            id
        | _ ->
            failwith "Expected procedure or function as root node" )
      parse_trees
  in
  let n_funcs = string_of_int (List.length func_names) in
  print_endline "Converting..." ;
  let gasts =
    List.mapi
      (fun i pt ->
        print_endline
          ( "Converting " ^ List.nth func_names i ^ " (" ^ string_of_int i ^ "/"
          ^ n_funcs ^ ")" ) ;
        try gallina_of_parse_tree 0 pt
        with Failure s ->
          if contains s "not yet supported" then (
            let err = "Failed to lift " ^ List.nth func_names i ^ ": " ^ s in
            print_endline err ; Comment err )
          else
            let err =
              "Failed to lift " ^ List.nth func_names i ^ ": Unknown error"
            in
            print_endline err ; Comment err )
      parse_trees
  in
  print_endline "Lifting..." ;
  let out =
    String.concat "\n"
      ( List.mapi
          (fun i ->
            print_endline
              ( "Lifting " ^ List.nth func_names i ^ " (" ^ string_of_int i
              ^ "/" ^ n_funcs ^ ")" ) ;
            string_of_gallina (i = 0) args.input_fn args.do_extract
              args.extract_language args.extract_path (List.nth func_names i) )
          gasts
      @ ["Compute (main fresh_store)."] )
  in
  print_endline out ;
  let oc = open_out args.output_fn in
  Printf.fprintf oc "%s" out ; close_out oc
