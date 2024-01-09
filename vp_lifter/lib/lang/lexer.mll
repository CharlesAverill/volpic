{
    open Parser
    open Lexing
    open Vp_lifter.String_utils
    exception UnexpectedCharacter
}

let ident = ['A'-'Z' 'a'-'z' '_'] (['A'-'Z' 'a'-'z' '0'-'9' '_' '$'])* 
let digit = ['0'-'9']
let number = ['-']? digit+
let float = ['-']? digit+ ['.'] digit+ (['E'] ['+' '-'] digit+)?
let hex = (['A'-'F' 'a'-'f' '0'-'9'])*
let non_comma = (['\032' - '\126'] # [','])+
let non_semicolon = (['\032' - '\126'] # [';'])+

rule token = parse
    | [' ' '\t' '\r' '\n']          { token lexbuf }
    | '('                           { LEFT_PARENTHESIS }
    | ')'                           { RIGHT_PARENTHESIS }
    | '['                           { LEFT_BRACE }
    | ']'                           { RIGHT_BRACE }
    | '<'                           { LEFT_BRACKET }
    | '>'                           { RIGHT_BRACKET }
    | ':'                           { COLON }
    | ','                           { COMMA }
    | '='                           { EQUALS }
    | '$'                           { DOLLAR }
    | '^'                           { CARROT }
    | ';'                           { SEMICOLON }
    | '.'                           { DOT }
    | '`'                           { TICK }
    | "<emptynode>"                 { EMPTYNODE }
    | "addn"                        { ADDN }
    | "muln"                        { MULN }
    | "subn"                        { SUBN }
    | "divn"                        { DIVN }
    | "symdifn"                     { SYMDIFN }
    | "modn"                        { MODN }
    | "assignn"                     { ASSIGNN }
    | "loadn"                       { LOADN }
    | "rangen"                      { RANGEN }
    | "ltn"                         { LTN }
    | "lten"                        { LTEN }
    | "gtn"                         { GTN }
    | "gten"                        { GTEN }
    | "equaln"                      { EQUALN }
    | "unequaln"                    { UNEQUALN }
    | "inn"                         { INN }
    | "orn"                         { ORN }
    | "xorn"                        { XORN }
    | "shrn"                        { SHRN }
    | "shln"                        { SHLN }
    | "slashn"                      { SLASHN }
    | "andn"                        { ANDN }
    | "subscriptn"                  { SUBSCRIPTN }
    | "derefn"                      { DEREFN }
    | "addrn"                       { ADDRN }
    | "ordconstn"                   { ORDCONSTN }
    | "typeconvn"                   { TYPECONVN }
    | "calln"                       { CALLN }
    | "callparan"                   { CALLPARAN }
    | "realconstn"                  { REALCONSTN }
    | "unaryminusn"                 { UNARYMINUSN }
    | "unaryplusn"                  { UNARYPLUSN }
    | "asmn"                        { ASMN }
    | "vecn"                        { VECN }
    | "pointerconstn"               { POINTERCONSTN }
    | "stringconstn"                { STRINGCONSTN }
    | "notn"                        { NOTN }
    | "inlinen"                     { INLINEN }
    | "niln"                        { NILN }
    | "errorn"                      { ERRORN }
    | "typen"                       { TYPEN }
    | "setelementn"                 { SETELEMENTN }
    | "setconstn"                   { SETCONSTN }
    | "blockn"                      { BLOCKN }
    | "statementn"                  { STATEMENTN }
    | "ifn"                         { IFN }
    | "breakn"                      { BREAKN }
    | "continuen"                   { CONTINUEN }
    | "whilerepeatn"                { WHILEREPEATN }
    | "forn"                        { FORN }
    | "exitn"                       { EXITN }
    | "casen"                       { CASEN }
    | "caseblock"                   { CASEBLOCK }
    | "labeln"                      { LABELN }
    | "goton"                       { GOTON }
    | "tryexceptn"                  { TRYEXCEPTN }
    | "raisen"                      { RAISEN }
    | "tryfinallyn"                 { TRYFINALLYN }
    | "onn"                         { ONN }
    | "isn"                         { ISN }
    | "asn"                         { ASN }
    | "starstarn"                   { STARSTARN }
    | "arrayconstructn"             { ARRAYCONSTRUCTN }
    | "arrayconstructrangen"        { ARRAYCONSTRUCTRANGEN }
    | "tempcreaten"                 { TEMPCREATEN }
    | "temprefn"                    { TEMPREFN }
    | "tempdeleten"                 { TEMPDELETEN }
    | "addoptn"                     { ADDOPTN }
    | "nothingn"                    { NOTHINGN }
    | "loadvmtaddrn"                { LOADVMTADDRN }
    | "guidconstn"                  { GUIDCONSTN }
    | "rttin"                       { RTTIN }
    | "loadparentfpn"               { LOADPARENTFPN }
    | "objcselectorn"               { OBJCSELECTORN }
    | "objcprotocoln"               { OBJCPROTOCOLN }
    | "specializen"                 { SPECIALIZEN }
    | "finalizetempsn"              { FINALIZETEMPSN }
    | "pos"                         { POS }
    | "nil"                         { NIL }
    | "<nil>"                       { NILBRACKETS }
    | "<no type symbol>"            { NOTYPESYM }
    | "resultdef"                   { RESULTDEF }
    | "loc"                         { LOC }
    | "expectloc"                   { EXPECTLOC }
    | "flags"                       { FLAGS }
    | "cmplx"                       { CMPLX }
    | "var"                         { VAR }
    | "const"                       { CONST }
    | "left"                        { LEFT }
    | "tempinit"                    { TEMPINIT }
    | "blockid"                     { BLOCKID }
    | "else"                        { ELSE }
    | "out"                         { OUT }
    | "{Open}"                      { BRACEOPEN }
    | "Array"                       { ARRAY }
    | "Of"                          { OF }
    | "Formal type"                 { FORMAL_TYPE }
    | '\"' ((['\032' - '\126'] # ['\\' '"'])* as lxm) '\"'
                                    { STRING (lxm) }
    | number as lxm                 { NUMBER (int_of_string lxm) }
    | float as lxm                  { let x = (List.fold_left 
                                        (fun acc s -> 
                                             if contains acc s then string_before_substr acc s else acc) 
                                        lxm ["E"] )
                                      in
                                        FLOAT (float_of_string x) }
    | ident                         { IDENTIFIER (lexeme lexbuf) }
    | hex as lxm                    { HEX (lxm) }
    | eof                           { EOF }
    | _ { raise UnexpectedCharacter }

and comment = parse
    | "*)"                          { token lexbuf }
    | eof                           { failwith "Unexpected EOF" }
    | _                             { comment lexbuf }
