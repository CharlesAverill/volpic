{
    open Parser
    open Lexing
    exception UnexpectedCharacter
}

let ident = ['A'-'Z' 'a'-'z' '_'] (['A'-'Z' 'a'-'z' '0'-'9' '_'])* 
let digit = ['0'-'9']
let number = digit+
let hex = (['A'-'F' 'a'-'f' '0'-'9'])*
let non_comma = (['\032' - '\126'] # [','])*

rule token = parse
    | [' ' '\t' '\r' '\n']          { token lexbuf }
    | '('                           { LEFT_PARENTHESIS }
    | ')'                           { RIGHT_PARENTHESIS }
    | '['                           { LEFT_BRACE }
    | ']'                           { RIGHT_BRACE }
    | ':'                           { COLON }
    | ','                           { COMMA }
    | '='                           { EQUALS }
    | '$'                           { DOLLAR }
    | '^'                           { CARROT }
    | ';'                           { SEMICOLON }
    | "blockn"                      { BLOCKN }
    | "nothingn"                    { NOTHINGN }
    | "statementn"                  { STATEMENTN }
    | "calln"                       { CALLN }
    | "assignn"                     { ASSIGNN }
    | "loadn"                       { LOADN }
    | "ordconstn"                   { ORDCONSTN }
    | "vecn"                        { VECN }
    | "tempcreaten"                 { TEMPCREATEN }
    | "temprefn"                    { TEMPREFN }
    | "typeconvn"                   { TYPECONVN }
    | "callparan"                   { CALLPARAN }
    | "derefn"                      { DEREFN }
    | "tempdeleten"                 { TEMPDELETEN }
    | "stringconstn"                { STRINGCONSTN }
    | "pos"                         { POS }
    | "nil"                         { NIL }
    | "<nil>"                       { NILBRACKETS }
    | "resultdef"                   { RESULTDEF }
    | "loc"                         { LOC }
    | "expectloc"                   { EXPECTLOC }
    | "flags"                       { FLAGS }
    | "cmplx"                       { CMPLX }
    | "var"                         { VAR }
    | "const"                       { CONST }
    | '\"' ((['\032' - '\126'] # ['\\' '"'])* as lxm) '\"'   
                                    { STRING (lxm) }
    | number as lxm                 { NUMBER (int_of_string lxm) }
    | ident                         { IDENTIFIER (lexeme lexbuf) }
    | hex as lxm                    { HEX (lxm) }
    | eof                           { EOF }
    | _ { raise UnexpectedCharacter }

and comment = parse
    | "*)"                          { token lexbuf }
    | eof                           { failwith "Unexpected EOF" }
    | _                             { comment lexbuf }
