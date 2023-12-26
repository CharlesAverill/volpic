open Lang.Read_tree
open Vp_lifter.Parse_tree

let () =
  print_endline "Hello World" ;
  print_endline
    (string_of_parse_tree
       (List.hd (read_tree (List.nth (Array.to_list Sys.argv) 1))) )
