{
    open Parser
    open Lexing
    exception UnexpectedCharacter
}

let ident = ['A'-'Z' 'a'-'z' '_'] (['A'-'Z' 'a'-'z' '0'-'9' '_'])* 
let digit = ['0'-'9']
let number = digit*
let non_comma = (['\032' - '\126'] # [','])*

rule token = parse
    | [' ' '\t' '\r' '\n']          { token lexbuf }
    | '('                           { LEFT_PARENTHESIS }
    | ')'                           { RIGHT_PARENTHESIS }
    | ','                           { COMMA }
    | number as lxm                 { NUMBER (int_of_string lxm) }
    | ident                         { IDENTIFIER (lexeme lexbuf) }
    | eof                           { EOF }
    | _ { raise UnexpectedCharacter }

and comment = parse
    | "*)"                          { token lexbuf }
    | eof                           { failwith "Unexpected EOF" }
    | _                             { comment lexbuf }
