open Lang.Read_tree
open Vp_lifter.Parse_tree
open Vp_lifter.Generator
open Vp_lifter.Converter

let () =
  let parse_tree = List.hd (read_tree (List.nth (Array.to_list Sys.argv) 1)) in
  (* print_endline (string_of_gallina (gallina_of_parse_tree parse_tree)) *)
  converter_test ()
