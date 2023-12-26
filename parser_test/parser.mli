type token =
  | NUMBER of (int)
  | IDENTIFIER of (string)
  | LEFT_PARENTHESIS
  | RIGHT_PARENTHESIS
  | COMMA
  | EOF

val main :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> Tree.tree list
