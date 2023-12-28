type arguments =
  { fpc_flags: string
  ; input_fn: string
  ; output_fn: string
  ; tree_log: string
  ; do_compile: bool }

let parse_arguments () =
  let files = ref [] in
  let fpc_flags = ref "" in
  let tree_log = ref "tree.log" in
  let do_compile = ref true in
  let speclist =
    Arg.
      [ ( "-fpc-flags"
        , Arg.Set_string fpc_flags
        , "Flags passed to FPC during compilation" )
      ; ( "-use-tree"
        , Arg.String
            (fun s ->
              do_compile := false ;
              tree_log := s )
        , "Uses a provided tree.log file instead of calling fpc. If empty, \
           will look for [basename].tree.log" ) ]
  in
  let usage_msg = "Usage: vp_lifter <INPUT> <OUTPUT>? [options]" in
  Arg.parse speclist (fun n -> files := n :: !files) usage_msg ;
  let input_fn, output_fn =
    match List.length !files with
    | 0 ->
        failwith "Input filename mandatory"
    | 1 ->
        let input_fn = List.hd !files in
        (input_fn, Filename.remove_extension input_fn ^ ".v")
    | 2 ->
        (List.hd !files, List.hd (List.tl !files))
    | _ ->
        failwith
          ( "Not sure what to do with files ["
          ^ String.concat " " (List.tl (List.tl !files))
          ^ "]" )
  in
  { fpc_flags= !fpc_flags
  ; input_fn
  ; output_fn
  ; tree_log=
      ( if !tree_log = "" then
          String.concat "" [Filename.remove_extension input_fn; ".tree.log"]
        else !tree_log )
  ; do_compile= !do_compile }
