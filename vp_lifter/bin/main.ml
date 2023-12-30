open Lang.Read_tree
open Vp_lifter.Parse_tree
open Vp_lifter.Generator
open Vp_lifter.Converter
open Argparse
open Filename

let get_parse_tree fn args =
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
  let parse_tree = List.hd (read_tree args.tree_log) in
  if args.do_compile then Sys.chdir dir ;
  parse_tree

let () =
  let args = parse_arguments () in
  let parse_tree = get_parse_tree args.input_fn args in
  let gast = gallina_of_parse_tree parse_tree in
  let out =
    string_of_gallina gast args.input_fn args.do_extract args.extract_language
      args.extract_path
  in
  print_endline out ;
  let oc = open_out args.output_fn in
  Printf.fprintf oc "%s" out ; close_out oc
