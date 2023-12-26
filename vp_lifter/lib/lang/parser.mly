%{
    open Vp_lifter.Parse_tree
%}

%token BLOCKN NOTHINGN STATEMENTN CALLN ASSIGNN LOADN ORDCONSTN VECN TEMPCREATEN TEMPREFN TYPECONVN CALLPARAN DEREFN TEMPDELETEN STRINGCONSTN
%token <string> IDENTIFIER
%token <string> STRING
%token <string> HEX
%token <int>    NUMBER

%token LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_BRACE RIGHT_BRACE
%token COLON COMMA EQUALS DOLLAR CARROT SEMICOLON
%token NIL RESULTDEF POS LOC EXPECTLOC FLAGS CMPLX NILBRACKETS VAR CONST
%token EOF

%start main
%type <Vp_lifter.Parse_tree.parse_tree_node list> main node_list
%type <Vp_lifter.Parse_tree.parse_tree_node> node
%type <Vp_lifter.Parse_tree.parse_tree_node_type> node_type
%type <string> resultdef typestrptr qualified_type typestr
%type <Vp_lifter.Parse_tree.flag list> flags flags_list
%type <(string * Vp_lifter.Parse_tree.pt_vtype) list> data_list data_seq
%type <Vp_lifter.Parse_tree.pt_vtype> data_val
%type <(string * Vp_lifter.Parse_tree.pt_vtype)> data individual_data
%type <(string * Vp_lifter.Parse_tree.optional) list> optional_list optionals
%type <((string * Vp_lifter.Parse_tree.optional) list) option> option(optionals)
%type <(string * Vp_lifter.Parse_tree.optional)> optional
%type <string list> opt_list separated_nonempty_list(SEMICOLON, qualified_type) loption(separated_nonempty_list(SEMICOLON,qualified_type))

%%

main :
      EOF  { [] }
    | node { [$1] }

node_list : { [] }
    | node node_list { $1 :: $2 }

node :
    LEFT_PARENTHESIS 
        node_type COMMA
        resultdef COMMA
        POS EQUALS LEFT_PARENTHESIS NUMBER COMMA NUMBER RIGHT_PARENTHESIS COMMA
        LOC EQUALS IDENTIFIER COMMA
        EXPECTLOC EQUALS IDENTIFIER COMMA
        FLAGS EQUALS flags COMMA
        CMPLX EQUALS NUMBER
        optionals?
        data_list
        node_list
    RIGHT_PARENTHESIS  
    {   
        (* let o = match $29 with None -> [] | Some l -> l in *)
        { 
            pt_type = $2;
            resultdef = return_type_of_string $4;
            pos = ($9, $11);
            loc = loc_of_string $16;
            expectloc = loc_of_string $20;
            flags = $24;
            cmplx = $28;
            optionals = [];
            data = $30;
            children = $31;
        }
    }

optionals : COMMA optional_list { $2 }
optional_list : 
      optional                  { [$1] }
    | optional COMMA optional_list    { $1 :: $3 }
optional:
      IDENTIFIER EQUALS IDENTIFIER    { ($1, OString $3) }
    | IDENTIFIER EQUALS LEFT_BRACE opt_list RIGHT_BRACE    { ($1, OList $4) }
opt_list :  { [] }
    | IDENTIFIER                { [$1] }
    | IDENTIFIER COMMA opt_list { $1 :: $3}

node_type :
      NOTHINGN      { Nothing }
    | BLOCKN        { Block }
    | STATEMENTN    { Statement }
    | CALLN         { Call }
    | ASSIGNN       { Assignment }
    | LOADN         { Load }
    | ORDCONSTN     { Ordconst }
    | VECN          { Vec }
    | TEMPCREATEN   { Tempcreate }
    | TEMPREFN      { Tempref }
    | TYPECONVN     { Typeconv }
    | CALLPARAN     { Callpara }
    | DEREFN        { Deref }
    | TEMPDELETEN   { Tempdelete }
    | STRINGCONSTN  { Stringconst }

resultdef :
      RESULTDEF EQUALS IDENTIFIER           { $3 }
    | RESULTDEF EQUALS DOLLAR IDENTIFIER EQUALS STRING { $6 }
    | RESULTDEF EQUALS typestr EQUALS STRING    { $5 }
    | RESULTDEF EQUALS NILBRACKETS          { "<nil>" }

flags :
      LEFT_BRACE RIGHT_BRACE            { [] }
    | LEFT_BRACE flags_list RIGHT_BRACE { $2 }

flags_list : 
      IDENTIFIER                    { [flag_of_string $1] }
    | IDENTIFIER COMMA flags_list   { (flag_of_string $1) :: $3 }

data_list : { [] }
    | NIL data_list         { $2 }
    | data data_list        { $1 :: $2 }

data:
    individual_data                 { $1 }
    | individual_data COMMA data_seq                      { ("", List ($1 :: $3)) }

individual_data :
      IDENTIFIER EQUALS data_val  { ($1, $3) }
    | IDENTIFIER COLON IDENTIFIER   { ($1, String $3) }
    | IDENTIFIER EQUALS             { ($1, Blank) }
    | FLAGS EQUALS flags            { ("flags", Flags $3) }
    | flags                         { ("nolabel_flags", Flags $1) }

data_val :
      IDENTIFIER    { String $1 }
    | NUMBER        { Integer $1 }
    | IDENTIFIER EQUALS STRING  { String $3 }
    | DOLLAR IDENTIFIER COLON typestr SEMICOLON { String ("$" ^ $2 ^ ":" ^ $4) }
    | DOLLAR IDENTIFIER typestr SEMICOLON { String $3 }
    | DOLLAR HEX        { Integer (int_of_string ("0x" ^ (Str.string_after $2 1))) }

data_seq :
      individual_data                  { [$1] }
    | individual_data COMMA data_seq   { $1 :: $3 }
    | LEFT_PARENTHESIS data_list RIGHT_PARENTHESIS { $2 }

typestr :
      qualified_type         { $1 }
    | LEFT_PARENTHESIS separated_list(SEMICOLON, qualified_type) RIGHT_PARENTHESIS { String.concat ";" $2 }

qualified_type :
      typestrptr        { $1 }
    | VAR typestrptr    { $2 }
    | CONST typestrptr  { $2 }

typestrptr :
      IDENTIFIER    { $1 }
    | CARROT typestr   { "^" ^ $2 }
