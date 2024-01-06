open Lexing

exception SyntaxError of string * Lexing.position

let syntax_error message pos = raise (SyntaxError (message, pos))

let contents = ref ""

let parse_error lexbuf =
  syntax_error
    ( if lexbuf.Lexing.lex_curr_pos == lexbuf.Lexing.lex_last_pos then
        let display_contents =
          try
            " -\n"
            ^ String.sub !contents
                (max 0 (lexbuf.Lexing.lex_curr_pos - 120))
                120
          with _ -> Lexing.lexeme lexbuf
        in
        "Unexpected end of file, last read " ^ display_contents
      else
        let display_contents =
          try
            " -\n"
            ^ String.sub !contents (max 0 (lexbuf.Lexing.lex_curr_pos - 80)) 80
          with Invalid_argument _ -> ""
        in
        "Unexpected token '" ^ Lexing.lexeme lexbuf ^ "' at "
        ^ string_of_int lexbuf.Lexing.lex_curr_pos
        ^ display_contents )
    (Lexing.lexeme_start_p lexbuf)

let parse lexbuf =
  try Parser.main Lexer.token lexbuf with
  | Failure s ->
      failwith s
  | Not_found ->
      failwith "String searching failed"
  | Invalid_argument s ->
      raise (Invalid_argument s)
  | _ ->
      parse_error lexbuf

let parse_file fn =
  let lexbuf = Lexing.from_channel (open_in fn) in
  lexbuf.lex_curr_p <- {lexbuf.lex_curr_p with pos_fname= fn} ;
  parse lexbuf

let parse_string s _fn =
  contents := s ;
  let lexbuf = Lexing.from_string s in
  (* lexbuf.lex_curr_p <- {lexbuf.lex_curr_p with pos_fname= fn} ; *)
  parse lexbuf
