open Input

let done_reading = ref false

let in_header = ref false

let to_parse = ref ""

let all_chars_are_star str =
  let is_star c = c = '*' in
  let rec check_chars index =
    if index < String.length str then
      if String.get str index = '\n' then check_chars (index + 1)
        (* Skip newline characters *)
      else if not (is_star (String.get str index)) then false
      else check_chars (index + 1)
    else true
  in
  String.length str > 0 && check_chars 0

let contains s1 s2 =
  let re = Str.regexp_string s2 in
  try
    ignore (Str.search_forward re s1 0) ;
    true
  with Not_found -> false

let process_line _line_number line_content =
  if contains line_content "firstpass" then done_reading := true
  else if all_chars_are_star line_content then in_header := not !in_header
  else if (not !in_header) && String.length (String.trim line_content) > 0 then
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

let process_file fn =
  let in_channel = open_in fn in
  try
    let rec read_lines line_number =
      if !done_reading then ()
      else
        match input_line in_channel with
        | exception End_of_file ->
            ()
        | line_content ->
            process_line line_number line_content ;
            read_lines (line_number + 1)
    in
    read_lines 1
  with e -> close_in in_channel ; raise e

let read_tree fn =
  process_file fn ;
  print_endline (String.trim !to_parse) ;
  parse_string (String.trim !to_parse ^ "\n") fn
