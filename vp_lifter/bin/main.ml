open Lang.Read_tree
open Vp_lifter.Parse_tree
open Vp_lifter.Generator
open Vp_lifter.Converter
open Argparse
open Filename

let get_parse_trees fn args =
  let dir = Sys.getcwd () in
  if args.do_compile then (
    Sys.chdir (dirname fn) ;
    let cmd = String.concat " " ["fpc"; "-vp"; args.fpc_flags; basename fn] in
    match Sys.command cmd with
    | 0 ->
        ()
    | n ->
        failwith
          ( "Tree generation command `" ^ cmd ^ "` failed with exit code "
          ^ string_of_int n ) ) ;
  let parse_trees = read_tree args.tree_log in
  if args.do_compile then Sys.chdir dir ;
  parse_trees

let () =
  let args = parse_arguments () in
  let parse_trees = get_parse_trees args.input_fn args in
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
  let gasts = List.map (gallina_of_parse_tree 0) parse_trees in
  let out =
    String.concat "\n"
      (List.mapi
         (fun i ->
           string_of_gallina (i = 0) args.input_fn args.do_extract
             args.extract_language args.extract_path (List.nth func_names i) )
         gasts )
  in
  print_endline out ;
  let oc = open_out args.output_fn in
  Printf.fprintf oc "%s" out ; close_out oc
