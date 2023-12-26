%{
    open Vp_lifter.Parse_tree
%}

%token BLOCKN NOTHINGN STATEMENTN CALLN ASSIGNN LOADN ORDCONSTN VECN TEMPCREATEN 
    TEMPREFN TYPECONVN CALLPARAN DEREFN TEMPDELETEN STRINGCONSTN FORN WHILEN MULN
    SUBN SUBSCRIPTN IFN UNEQUALN
%token <string> IDENTIFIER
%token <string> STRING
%token <int>    NUMBER
%token <string> HEX

%token LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_BRACE RIGHT_BRACE
%token COMMA EQUALS DOLLAR CARROT SEMICOLON NEWLINE COLON DOT
%token NIL RESULTDEF POS LOC EXPECTLOC FLAGS CMPLX NILBRACKETS VAR CONST NOTYPESYM
    LEFT TEMPINIT
%token EOF

%start main
%type <Vp_lifter.Parse_tree.parse_tree_node list> main node_list
%type <Vp_lifter.Parse_tree.parse_tree_node option> node
%type <Vp_lifter.Parse_tree.parse_tree_node_type> node_type
%type <string> resultdef typestrptr qualified_type typestr ptypestr label
%type <Vp_lifter.Parse_tree.flag list> flags flags_list
%type <(string * Vp_lifter.Parse_tree.pt_vtype) list> data_list data_seq nonempty_list(data)
%type <Vp_lifter.Parse_tree.pt_vtype> data_val
%type <(string * Vp_lifter.Parse_tree.pt_vtype) list * Vp_lifter.Parse_tree.parse_tree_node list> node_data_list
%type <(string * Vp_lifter.Parse_tree.pt_vtype)> data individual_data
%type <(string * Vp_lifter.Parse_tree.optional) list> optional_list optionals
%type <((string * Vp_lifter.Parse_tree.optional) list) option> option(optionals)
%type <(string * Vp_lifter.Parse_tree.optional)> optional
%type <string list> opt_list separated_nonempty_list(SEMICOLON, qualified_type) loption(separated_nonempty_list(SEMICOLON,qualified_type))

%%

main :
      EOF  { [] }
    | node { match $1 with None -> [] | Some n -> [n] }

node_list : { [] }
    | node node_list { match $1 with None -> $2 | Some n -> n :: $2 }

node :
    label NIL { None } |
    label = label 
    LEFT_PARENTHESIS 
        nt = node_type COMMA
        rd = resultdef COMMA
        POS EQUALS LEFT_PARENTHESIS ln = NUMBER COMMA cn = NUMBER RIGHT_PARENTHESIS COMMA
        LOC EQUALS loc = IDENTIFIER COMMA
        EXPECTLOC EQUALS eloc = IDENTIFIER COMMA
        FLAGS EQUALS flags = flags COMMA
        CMPLX EQUALS cmplx = NUMBER
        opts = optionals?
        ndl = node_data_list
    RIGHT_PARENTHESIS  
    {   
        Some { 
            pt_type = nt;
            label = label;
            resultdef = return_type_of_string rd;
            pos = (ln, cn);
            loc = loc_of_string loc;
            expectloc = loc_of_string eloc;
            flags = flags;
            cmplx = cmplx;
            optionals = (match opts with None -> [] | Some l -> l);
            data = fst ndl;
            children = snd ndl;
        }
    }

node_data_list : node_list data_list { ($2, $1) } | data_list node_list { ($1, $2) }

label : { "" }
    | LEFT EQUALS { "left" }
    | TEMPINIT EQUALS { "tempinit" }

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
    | FORN          { For }
    | WHILEN        { While }
    | MULN          { Mul }
    | SUBN          { Sub }
    | SUBSCRIPTN    { Subscript }
    | IFN           { If }
    | UNEQUALN      { Unequal }

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
    | nonempty_list(data)    { $1 }

data:
    individual_data                 { $1 }
    | individual_data COMMA data_seq                      { ("", List ($1 :: $3)) }

individual_data :
      IDENTIFIER EQUALS data_val  { ($1, $3) }
    | IDENTIFIER COLON IDENTIFIER   { ($1, Str $3) }
    | IDENTIFIER EQUALS             { ($1, Blank) }
    | FLAGS EQUALS flags            { ("flags", Flags $3) }
    | flags                         { ("nolabel_flags", Flags $1) }

data_val :
      IDENTIFIER    { Str $1 }
    | NUMBER        { Integer $1 }
    | IDENTIFIER EQUALS STRING  { Str $3 }
    | DOLLAR IDENTIFIER COLON typestr SEMICOLON { Str ("$" ^ $2 ^ ":" ^ $4) }
    | DOLLAR IDENTIFIER ptypestr SEMICOLON { Str $3 }
    | IDENTIFIER COLON typestr SEMICOLON { Str ("$" ^ $1 ^ ":" ^ $3) }
    | IDENTIFIER ptypestr SEMICOLON { Str $2 }
    | DOLLAR HEX        { Integer (int_of_string ("0x" ^ (Str.string_after $2 1))) }

data_seq :
      individual_data                  { [$1] }
    | individual_data COMMA data_seq   { $1 :: $3 }
    | LEFT_PARENTHESIS data_list RIGHT_PARENTHESIS { $2 }

typestr :
        qualified_type      { $1 }
      | ptypestr            { $1 }
      | NOTYPESYM           { "" }
      | typestr DOT typestr { $1 ^ "." ^ $3 }

ptypestr : LEFT_PARENTHESIS separated_list(SEMICOLON, qualified_type) RIGHT_PARENTHESIS { String.concat ";" $2 }

qualified_type :
      typestrptr        { $1 }
    | VAR typestrptr    { $2 }
    | CONST typestrptr  { $2 }

typestrptr :
      IDENTIFIER    { $1 }
    | CARROT typestr   { "^" ^ $2 }
