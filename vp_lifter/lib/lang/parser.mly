%{
    open Vp_lifter.Parse_tree
%}

%token EMPTYNODE ADDN MULN SUBN DIVN SYMDIFN MODN ASSIGNN LOADN RANGEN LTN LTEN 
    GTN GTEN EQUALN UNEQUALN INN ORN XORN SHRN SHLN SLASHN ANDN SUBSCRIPTN DEREFN 
    ADDRN ORDCONSTN TYPECONVN CALLN CALLPARAN REALCONSTN UNARYMINUSN UNARYPLUSN 
    ASMN VECN POINTERCONSTN STRINGCONSTN NOTN INLINEN NILN ERRORN TYPEN SETELEMENTN 
    SETCONSTN BLOCKN STATEMENTN IFN BREAKN CONTINUEN WHILEREPEATN FORN EXITN CASEN 
    LABELN GOTON TRYEXCEPTN RAISEN TRYFINALLYN ONN ISN ASN STARSTARN ARRAYCONSTRUCTN 
    ARRAYCONSTRUCTRANGEN TEMPCREATEN TEMPREFN TEMPDELETEN ADDOPTN NOTHINGN LOADVMTADDRN 
    GUIDCONSTN RTTIN LOADPARENTFPN OBJCSELECTORN OBJCPROTOCOLN SPECIALIZEN FINALIZETEMPSN
%token <string> IDENTIFIER STRING HEX
%token <int>    NUMBER
%token <float>  FLOAT

%token LEFT_PARENTHESIS RIGHT_PARENTHESIS LEFT_BRACE RIGHT_BRACE LEFT_BRACKET RIGHT_BRACKET
    TICK
%token COMMA EQUALS DOLLAR CARROT SEMICOLON COLON DOT
%token NIL RESULTDEF POS LOC EXPECTLOC FLAGS CMPLX NILBRACKETS VAR CONST NOTYPESYM
    LEFT TEMPINIT CASEBLOCK BLOCKID ELSE OUT BRACEOPEN ARRAY OF FORMAL_TYPE BRACEDYNAMIC
%token EOF

%start main
%type <Vp_lifter.Parse_tree.parse_tree_node list> main node_list
%type <Vp_lifter.Parse_tree.parse_tree_node option> node
%type <Vp_lifter.Parse_tree.parse_tree_node_type> node_type
%type <string> resultdef typestrptr qualified_type typestr ptypestr label
%type <int> cmplx 
%type <int option> option(cmplx)
%type <Vp_lifter.Parse_tree.flag list> flags flags_list
%type <(Vp_lifter.Parse_tree.flag list) option> option(flags)
%type <(string * Vp_lifter.Parse_tree.pt_vtype) list> data_list data_seq nonempty_list(data)
%type <Vp_lifter.Parse_tree.pt_vtype> data_val
%type <(string * Vp_lifter.Parse_tree.pt_vtype) list * Vp_lifter.Parse_tree.parse_tree_node list> node_data_list
%type <(string * Vp_lifter.Parse_tree.pt_vtype)> data individual_data
%type <(string * Vp_lifter.Parse_tree.optional) list> optional_list optionals
%type <((string * Vp_lifter.Parse_tree.optional) list) option> option(optionals)
%type <(string * Vp_lifter.Parse_tree.optional)> optional
%type <string list> opt_list separated_nonempty_list(SEMICOLON, qualified_type) loption(separated_nonempty_list(SEMICOLON,qualified_type))
%type <unit option> option(COMMA)

%%

main : node_list { $1 }

node_list : { [] }
    | EOF { [] }
    | node node_list { match $1 with None -> $2 | Some n -> n :: $2 }

node :
    label NIL { None } |
    label = label
    LEFT_PARENTHESIS CASEBLOCK BLOCKID COLON num = NUMBER n = node RIGHT_PARENTHESIS {
        match n with
        | Some n' -> Some { n' with data = (("caseblock_blockid", Integer num) :: n'.data); label = label }
        | None -> None
    } |
    label = label
    LEFT_PARENTHESIS ELSE COLON num = NUMBER n = node RIGHT_PARENTHESIS {
        match n with
        | Some n' -> Some { n' with data = (("caseblock_else", Integer num) :: n'.data); label = label }
        | None -> None
    } |
    label = label 
    LEFT_PARENTHESIS 
        nt = node_type COMMA
        rd = resultdef COMMA
        POS EQUALS LEFT_PARENTHESIS ln = NUMBER COMMA cn = NUMBER RIGHT_PARENTHESIS COMMA
        LOC EQUALS loc = IDENTIFIER COMMA
        EXPECTLOC EQUALS eloc = IDENTIFIER COMMA
        FLAGS EQUALS flags = flags
        cmplx = cmplx?
        opts = optionals?
        flags?
        ndl = node_data_list
    RIGHT_PARENTHESIS  
    {
        Some { 
            is_func = false;
            func_type = Nil;
            pt_type = nt;
            label = label;
            resultdef = return_type_of_string rd;
            pos = (ln, cn);
            loc = loc_of_string loc;
            expectloc = loc_of_string eloc;
            flags = flags;
            cmplx = (match cmplx with Some n -> n | _ -> 0);
            optionals = (match opts with None -> [] | Some l -> l);
            data = fst ndl;
            children = snd ndl;
        }
    }

cmplx : COMMA CMPLX EQUALS NUMBER { $4 }

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
      EMPTYNODE           { Emptynode }
    | ADDN                { Add }
    | MULN                { Mul }
    | SUBN                { Sub }
    | DIVN                { Div }
    | SYMDIFN             { Symdif }
    | MODN                { Mod }
    | ASSIGNN             { Assign }
    | LOADN               { Load }
    | RANGEN              { Range }
    | LTN                 { Lt }
    | LTEN                { Lte }
    | GTN                 { Gt }
    | GTEN                { Gte }
    | EQUALN              { Equal }
    | UNEQUALN            { Unequal }
    | INN                 { In }
    | ORN                 { Or }
    | XORN                { Xor }
    | SHRN                { Shr }
    | SHLN                { Shl }
    | SLASHN              { Slash }
    | ANDN                { And }
    | SUBSCRIPTN          { Subscript }
    | DEREFN              { Deref }
    | ADDRN               { Addr }
    | ORDCONSTN           { Ordconst }
    | TYPECONVN           { Typeconv }
    | CALLN               { Call }
    | CALLPARAN           { Callpara }
    | REALCONSTN          { Realconst }
    | UNARYMINUSN         { Unaryminus }
    | UNARYPLUSN          { Unaryplus }
    | ASMN                { Asm }
    | VECN                { Vec }
    | POINTERCONSTN       { Pointerconst }
    | STRINGCONSTN        { Stringconst }
    | NOTN                { Not }
    | INLINEN             { Inline }
    | NILN                { Nil }
    | ERRORN              { Error }
    | TYPEN               { Type }
    | SETELEMENTN         { Setelement }
    | SETCONSTN           { Setconst }
    | BLOCKN              { Block }
    | STATEMENTN          { Statement }
    | IFN                 { If }
    | BREAKN              { Break }
    | CONTINUEN           { Continue }
    | WHILEREPEATN        { Whilerepeat }
    | FORN                { For }
    | EXITN               { Exit }
    | CASEN               { Case }
    | LABELN              { Label }
    | GOTON               { Goto }
    | TRYEXCEPTN          { Tryexcept }
    | RAISEN              { Raise }
    | TRYFINALLYN         { Tryfinally }
    | ONN                 { On }
    | ISN                 { Is }
    | ASN                 { As }
    | STARSTARN           { Starstar }
    | ARRAYCONSTRUCTN     { Arrayconstruct }
    | ARRAYCONSTRUCTRANGEN{ Arrayconstructrange }
    | TEMPCREATEN         { Tempcreate }
    | TEMPREFN            { Tempref }
    | TEMPDELETEN         { Tempdelete }
    | ADDOPTN             { Addopt }
    | NOTHINGN            { Nothing }
    | LOADVMTADDRN        { Loadvmtaddr }
    | GUIDCONSTN          { Guidconst }
    | RTTIN               { Rtti }
    | LOADPARENTFPN       { Loadparentfp }
    | OBJCSELECTORN       { Objcselector }
    | OBJCPROTOCOLN       { Objcprotocol }
    | SPECIALIZEN         { Specialize }
    | FINALIZETEMPSN      { Finalizetemps }

resultdef :
      RESULTDEF EQUALS IDENTIFIER           { $3 }
    | RESULTDEF EQUALS DOLLAR IDENTIFIER EQUALS STRING { $6 }
    | RESULTDEF EQUALS IDENTIFIER EQUALS STRING { $5 }
    | RESULTDEF EQUALS typestr EQUALS STRING    { if $5 = "<record type>" then $3 ^ $5 else $5 }
    | RESULTDEF EQUALS NILBRACKETS          { "<nil>" }

flags : LEFT_BRACE flags_list RIGHT_BRACE { $2 }

flags_list : { [] }
    | IDENTIFIER                    { [flag_of_string $1] }
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
    | STRING        { Str $1 }
    | NUMBER        { Integer $1 }
    | FLOAT         { Float $1 }
    | IDENTIFIER EQUALS STRING  { Str $3 }
    | DOLLAR IDENTIFIER COLON typestr SEMICOLON { Str ("$" ^ $2 ^ ":" ^ $4) }
    | IDENTIFIER SEMICOLON { ProcFunc ($1, "", "") }
    | DOLLAR IDENTIFIER SEMICOLON { ProcFunc ($2, "", "") }
    | IDENTIFIER COLON typestr SEMICOLON { Str ("$" ^ $1 ^ ":" ^ $3) }
    | DOLLAR IDENTIFIER ptypestr SEMICOLON { ProcFunc ($2, $3, "") }
    | DOLLAR IDENTIFIER ptypestr COLON qualified_type SEMICOLON { ProcFunc ($2, $3, $5) }
    | IDENTIFIER ptypestr SEMICOLON { ProcFunc ($1, $2, "") }
    | IDENTIFIER ptypestr COLON qualified_type SEMICOLON { ProcFunc ($1, $2, $4) }
    | DOLLAR HEX        { Integer (int_of_string ("0x" ^ (Str.string_after $2 1))) }

data_seq :
      individual_data                  { [$1] }
    | individual_data COMMA data_seq   { $1 :: $3 }
    | LEFT_PARENTHESIS data_list RIGHT_PARENTHESIS { $2 }

typestr :
        qualified_type      { $1 }
      | ptypestr            { $1 }
    //   | typestr DOT typestr { $1 ^ "." ^ $3 }

ptypestr : LEFT_PARENTHESIS separated_list(SEMICOLON, qualified_type) RIGHT_PARENTHESIS { String.concat ";" $2 }

qualified_type :
      typestrptr        { $1 }
    | VAR qualified_type    { $2 }
    | CONST qualified_type  { $2 }
    | OUT qualified_type    { $2 }
    | LEFT_BRACKET qualified_type RIGHT_BRACKET { $2 }
    | qualified_type DOT qualified_type { $1 ^ "." ^ $3 }
    | typestrptr EQUALS TICK typestrptr TICK { $1 ^ "=" ^ $4 }
    | NOTYPESYM     { "" }

typestrptr : 
      IDENTIFIER    { $1 }
    | CARROT typestr   { "^" ^ $2 }
    | ARRAY OF typestr              { "Array of " ^ $3 }
    | BRACEDYNAMIC ARRAY OF typestr      { "Array of " ^ $4 }
    | BRACEOPEN ARRAY OF typestr    { "Array of " ^ $4 }
    | FORMAL_TYPE                   { "Formal type" }
