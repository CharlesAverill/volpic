open Input
open Vp_lifter.Parse_tree
open Vp_lifter.String_utils
open Vp_lifter.Logging

let do_read = ref true

let in_header = ref false

let to_parse = ref ""

let get_func_name_type = ref false

let funcs : (return_type_root * string) list ref = ref []

let all_chars_are_star str =
  List.fold_left
    (fun acc c -> acc && c = '*')
    true
    (List.init (String.length str) (String.get str))

let contains s1 s2 =
  let re = Str.regexp_string s2 in
  try
    ignore (Str.search_forward re s1 0) ;
    true
  with Not_found -> false

let finish_func_entry content =
  if !funcs = [] then
    failwith "Shouldn't have an empty list when adding content to funcs"
  else if snd (List.hd !funcs) <> "" then ()
  else funcs := (fst (List.hd !funcs), content) :: List.tl !funcs

let process_line line_number line_content =
  (* let line_content = String.trim line_content in *)
  if line_number mod 10000 = 0 then _log Log_Debug (string_of_int line_number) ;
  if contains line_content "firstpass" then do_read := false
  else if contains line_content "after parsing" then (
    do_read := true ;
    get_func_name_type := true )
  else if all_chars_are_star line_content then (
    in_header := not !in_header ;
    if !in_header && List.length !funcs > 0 then (
      finish_func_entry !to_parse ;
      to_parse := "" ) )
  else if !get_func_name_type then (
    funcs := (return_type_root_of_string line_content, "") :: !funcs ;
    get_func_name_type := false )
  else if
    !do_read && (not !in_header) && String.length (String.trim line_content) > 0
  then
    (*
      There's a line like this in my input:
        proc = FpSignal(LongInt;signalhandler_t):<procedure variable type of procedure(LongInt);CDecl>;
      it seems like <> are being used as comment delimiters, while everywhere else they're being used
      as type braces. If "procedure vairable ..." was a type, I think it would be unnecessarily complex,
      hence why I'm considering this as a comment. To simplify the parser, I'm going to strip it from the
      input
    *)
    let replaced_line_content =
      Str.global_replace (Str.regexp ":<.*>;") ";" line_content
    in
    to_parse := String.concat "\n" [!to_parse; replaced_line_content]

let gen_header rtr =
  String.concat "\n"
    [ "*******************************************************************************"
    ; "after parsing"
    ; string_of_return_type_root rtr
    ; "*******************************************************************************"
    ]

let combine_funcs do_header =
  String.concat "\n"
    (List.map
       (fun (rtr, content) ->
         String.concat "\n"
           (remove_empties
              [(if do_header then gen_header rtr else ""); content] ) )
       !funcs )

let process_file fn =
  let in_channel = open_in fn in
  ( try
      let rec read_lines line_number =
        match input_line in_channel with
        | exception End_of_file ->
            ()
        | line_content ->
            if String.trim line_content = "" then ()
            else process_line line_number line_content ;
            read_lines (line_number + 1)
      in
      read_lines 1
    with e -> close_in in_channel ; raise e ) ;
  finish_func_entry !to_parse

let read_tree original_fn use_preproc =
  let proc_fn = original_fn ^ ".proc" in
  let use_preprocessed = use_preproc && Sys.file_exists proc_fn in
  if use_preprocessed then (
    _log Log_Info "Reading processed parse tree file" ;
    process_file proc_fn )
  else (
    _log Log_Info "Processing parse tree file" ;
    (try process_file original_fn with Sys_error s -> fatal rc_CompileError s) ;
    _log Log_Info ("Dumping processed file parse tree file to " ^ proc_fn) ;
    let oc = open_out proc_fn in
    Printf.fprintf oc "%s" (combine_funcs true) ;
    close_out oc ) ;
  (* List.rev *)
  let l = parse_string (combine_funcs false) original_fn in
  List.rev
    (List.mapi
       (fun i pt ->
         _log Log_Info
           ( "Parsing tree "
           ^ string_of_int (i + 1)
           ^ "/"
           ^ string_of_int (List.length l) ) ;
         {pt with is_func= true; func_type= fst (List.nth !funcs i)} )
       l )
