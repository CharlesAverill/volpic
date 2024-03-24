open Vp_lifter.Logging

let extract_lang_of_string s =
  match String.lowercase_ascii s with
  | "ocaml" | "ml" ->
      "OCaml"
  | "haskell" | "hs" ->
      "Haskell"
  | _ ->
      failwith ("Unrecognized extraction language \"" ^ s ^ "\"")

type arguments =
  { fpc_flags: string
  ; input_fn: string
  ; output_fn: string
  ; tree_log: string
  ; do_compile: bool
  ; do_extract: bool
  ; extract_language: string
  ; extract_path: string
  ; fpc_path: string
  ; use_preproc: bool
  ; no_main: bool }

let parse_arguments () =
  let files = ref [] in
  let fpc_flags = ref "" in
  let tree_log = ref "tree.log" in
  let do_compile = ref true in
  let do_extract = ref false in
  let extract_lang = ref "" in
  let extract_fp = ref "" in
  let fpc_path = ref "fpc" in
  let use_preproc = ref false in
  let no_main = ref false in
  let speclist =
    Arg.
      [ ( "-logging"
        , Arg.Int (fun i -> _GLOBAL_LOG_LEVEL := log_of_int i)
        , "Lowest level of logs to print, range is " ^ range_of_logs )
      ; ( "-fpc-args"
        , Arg.String (fun s -> fpc_flags := String.concat " " [!fpc_flags; s])
        , "Args passed to FPC during compilation" )
      ; ( "-use-tree"
        , Arg.String
            (fun s ->
              do_compile := false ;
              tree_log := s )
        , "Uses a provided tree.log file instead of calling fpc. If empty, \
           will look for [basename].tree.log" )
      ; ( "-extract"
        , Arg.String
            (fun s ->
              do_extract := true ;
              extract_lang := extract_lang_of_string s )
        , "Generates extraction commands for the following languages: {OCaml, \
           Haskell}" )
      ; ( "-extract-path"
        , Arg.Set_string extract_fp
        , "Path of extracted file relative to generated Coq file" )
      ; ( "-tex-mf"
        , Arg.Unit
            (fun _ ->
              fpc_flags :=
                String.concat " " [!fpc_flags; "-Fasysutils,baseunix,unix"] )
        , "Compile with flags for TeX and MF" )
      ; ( "-fpc-path"
        , Arg.Set_string fpc_path
        , "Path to FPC binary, defaults to 'fpc'" )
      ; ( "-use-preproc"
        , Arg.Set use_preproc
        , "Use a preprocessed tree.log if available. These files are emitted \
           on parsing. This option should only be used if the program isn't \
           changing (updates won't be detected)" )
      ; ("-no-main", Arg.Set no_main, "Don't lift the $main function") ]
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
  if !use_preproc then do_compile := false ;
  { fpc_flags= !fpc_flags
  ; input_fn
  ; output_fn
  ; tree_log=
      ( if !tree_log = "" then
          String.concat "/" [Filename.dirname input_fn; "tree.log"]
        else !tree_log )
  ; do_compile= !do_compile
  ; do_extract= !do_extract
  ; extract_language= !extract_lang
  ; extract_path= !extract_fp
  ; fpc_path= !fpc_path
  ; use_preproc= !use_preproc
  ; no_main= !no_main }
