open Lang.Read_tree
open Vp_lifter.Parse_tree
open Vp_lifter.Generator
open Vp_lifter.Converter
open Filename

let get_parse_tree fn =
  let dir = Sys.getcwd () in
  Sys.chdir (dirname fn) ;
  let cmd = "fpc -vp " ^ basename fn in
  ( match Sys.command cmd with
  | 0 ->
      ()
  | n ->
      failwith
        ( "Tree generation command `" ^ cmd ^ "` failed with exit code "
        ^ string_of_int n ) ) ;
  let parse_tree = List.hd (read_tree "tree.log") in
  Sys.chdir dir ; parse_tree

let () =
  let input_fn = Sys.argv.(1) in
  let output_fn =
    if Array.length Sys.argv > 2 then Sys.argv.(2)
    else remove_extension input_fn ^ ".v"
  in
  let parse_tree = get_parse_tree input_fn in
  let gast = gallina_of_parse_tree parse_tree in
  print_endline (string_of_gallina gast) ;
  let oc = open_out output_fn in
  Printf.fprintf oc "%s" (string_of_gallina gast) ;
  close_out oc
