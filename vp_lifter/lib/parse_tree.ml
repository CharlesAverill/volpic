open String_utils

type parse_tree_node_type =
  | Nothing
  | Block
  | Statement
  | Call
  | Assignment
  | Load
  | Ordconst
  | Vec
  | Tempcreate
  | Tempref
  | Typeconv
  | Callpara
  | Deref
  | Tempdelete
  | Stringconst
  | For
  | While
  | Mul
  | Sub
  | Subscript
  | If
  | Unequal
  | Add

let string_of_parse_tree_type = function
  | Nothing ->
      "nothingn"
  | Block ->
      "blockn"
  | Statement ->
      "statementn"
  | Call ->
      "calln"
  | Assignment ->
      "assignn"
  | Load ->
      "loadn"
  | Ordconst ->
      "ordconstn"
  | Vec ->
      "vecn"
  | Tempcreate ->
      "tempcreaten"
  | Tempref ->
      "temprefn"
  | Typeconv ->
      "typeconvn"
  | Callpara ->
      "callparan"
  | Deref ->
      "derefn"
  | Tempdelete ->
      "tempdeleten"
  | Stringconst ->
      "stringconstn"
  | For ->
      "forn"
  | While ->
      "whilen"
  | Mul ->
      "muln"
  | Sub ->
      "subn"
  | Subscript ->
      "subscript"
  | If ->
      "ifn"
  | Unequal ->
      "unequaln"
  | Add ->
      "addn"

type range = Unbounded | Range of (int * int)

let string_of_range = function
  | Unbounded ->
      ""
  | Range (a, b) ->
      "[" ^ string_of_int a ^ ".." ^ string_of_int b ^ "]"

let string_before_substr str sub =
  try
    Str.string_before str
      ( try Str.search_forward (Str.regexp_string sub) str 0
        with Not_found ->
          failwith ("Couldn't find substring " ^ sub ^ " in string " ^ str) )
  with Not_found ->
    failwith ("Couldn't find substring " ^ sub ^ " in string " ^ str)

let string_after_substr str sub =
  try
    Str.string_after str
      ( try
          Str.search_backward (Str.regexp_string sub) str (String.length str - 1)
          + String.length sub
        with Not_found ->
          failwith ("Couldn't find substring " ^ sub ^ " in string " ^ str) )
  with Not_found ->
    failwith ("Couldn't find substring " ^ sub ^ " in string " ^ str)

let range_of_string s =
  if s = "" then Unbounded
  else
    let s' = string_after_substr (string_before_substr s "]") "[" in
    let dd_pos = Str.search_forward (Str.regexp_string "..") s' 0 in
    Range
      ( int_of_string (Str.string_before s' dd_pos)
      , int_of_string (Str.string_after s' (dd_pos + 2)) )

type return_type_root =
  | Nil
  | Pointer of return_type_root
  | Untyped
  | Dword
  | Qword
  | Text
  | LongInt
  | ShortString
  | ShortInt
  | Char
  | Int64
  | ASCIIcode
  | Byte
  | Boolean
  | SmallInt
  | Twohalves
  | Record of string
  | Word
  | SmallNumber
  | StrNumber
  | String
  | MemoryWord
  | QuarterWord
  | HalfWord
  | LongWord
  | Eightbits
  | Bytefile
  | Wordfile
  | Windownumber
  | Commandcode
  | Array of (bool * range * return_type_root)
  | Procedure of (string * return_type list)
  | Function of (string * return_type list * return_type)

and return_type =
  | RT of return_type_root
  | Const of return_type_root
  | Var of return_type_root

let rec string_of_return_type_root = function
  | Nil ->
      "nil"
  | Pointer rt' ->
      "^" ^ string_of_return_type (RT rt')
  | Untyped ->
      "untyped"
  | Dword ->
      "Dword"
  | Qword ->
      "Qword"
  | Text ->
      "Text"
  | LongInt ->
      "LongInt"
  | ShortString ->
      "ShortString"
  | ShortInt ->
      "ShortInt"
  | Char ->
      "Char"
  | Int64 ->
      "Int64"
  | ASCIIcode ->
      "ASCIIcode"
  | Byte ->
      "Byte"
  | Boolean ->
      "Boolean"
  | SmallInt ->
      "SmallInt"
  | Twohalves ->
      "twohalves"
  | Record s ->
      s ^ " = <record type>"
  | Word ->
      "Word"
  | SmallNumber ->
      "smallnumber"
  | StrNumber ->
      "strnumber"
  | String ->
      "String"
  | MemoryWord ->
      "memoryword"
  | QuarterWord ->
      "quarterword"
  | HalfWord ->
      "halfword"
  | LongWord ->
      "longword"
  | Eightbits ->
      "eightbits"
  | Bytefile ->
      "bytefile"
  | Wordfile ->
      "wordfile"
  | Windownumber ->
      "windownumber"
  | Commandcode ->
      "commandcode"
  | Array (bp, r, rt) ->
      (if bp then "BitPacked " else "")
      ^ "Array" ^ string_of_range r ^ " Of "
      ^ string_of_return_type (RT rt)
  | Procedure (id, args) ->
      id ^ "(" ^ String.concat ";" (List.map string_of_return_type args) ^ ")"
  | Function (id, args, rt) ->
      Printf.sprintf "%s(%s):%s" id
        (String.concat ";" (List.map string_of_return_type args))
        (string_of_return_type rt)

and string_of_return_type : return_type -> string = function
  | RT rt ->
      string_of_return_type_root rt
  | Const rt ->
      "Constant " ^ string_of_return_type_root rt
  | Var rt ->
      "Var " ^ string_of_return_type_root rt

let rec return_type_root_of_string s =
  if String.length s = 0 then failwith "Can't parse return type of empty string" ;
  let bp = String.starts_with ~prefix:"BitPacked" s in
  if String.get s 0 = '^' then
    Pointer (return_type_root_of_string (String.sub s 1 (String.length s - 1)))
  else if bp || String.starts_with ~prefix:"Array" s then
    Array
      ( bp
      , range_of_string s
      , return_type_root_of_string
          (Str.string_after s
             (Str.search_backward (Str.regexp_string " ") s
                (String.length s - 1) ) ) )
  else if contains s "(" then
    if contains s ":" then
      Function
        ( string_before_substr s "("
        , [ return_type_of_string
              (string_after_substr (string_before_substr s ")") "(") ]
        , return_type_of_string (string_after_substr s ":") )
    else
      Procedure
        ( string_before_substr s "("
        , List.map return_type_of_string
            (remove_empties
               [string_after_substr (string_before_substr s ")") "("] ) )
  else if contains s ";" then Procedure (string_before_substr s ";", [])
  else if contains s "<record type>" then
    Record (string_before_substr s "<record type>")
  else
    match String.trim (String.lowercase_ascii s) with
    | "$main; register;" ->
        Procedure ("main", [])
    | "<nil>" ->
        Nil
    | "untyped" ->
        Untyped
    | "dword" ->
        Dword
    | "qword" ->
        Qword
    | "text" ->
        Text
    | "longint" ->
        LongInt
    | "shortstring" ->
        ShortString
    | "shortint" ->
        ShortInt
    | "char" ->
        Char
    | "int64" ->
        Int64
    | "asciicode" ->
        ASCIIcode
    | "byte" ->
        Byte
    | "boolean" ->
        Boolean
    | "smallint" ->
        SmallInt
    | "twohalves" ->
        Twohalves
    | "word" ->
        Word
    | "smallnumber" ->
        SmallNumber
    | "strnumber" ->
        StrNumber
    | "string" ->
        String
    | "memoryword" ->
        MemoryWord
    | "quarterword" ->
        QuarterWord
    | "halfword" ->
        HalfWord
    | "longword" ->
        LongWord
    | "eightbits" ->
        Eightbits
    | "bytefile" ->
        Bytefile
    | "wordfile" ->
        Wordfile
    | "windownumber" ->
        Windownumber
    | "commandcode" ->
        Commandcode
    | _ ->
        Record (String.trim (String.lowercase_ascii s))
(* failwith ("Unknown return type " ^ s) *)

and return_type_of_string s =
  if String.starts_with ~prefix:"Constant " s then
    Const (return_type_root_of_string (string_after_substr s "Constant "))
  else if String.starts_with ~prefix:"var " s then
    Var (return_type_root_of_string (string_after_substr s "var "))
  else RT (return_type_root_of_string s)

type loc = Loc_invalid

let string_of_loc = function Loc_invalid -> "LOC_INVALID"

let loc_of_string s =
  match s with
  | "LOC_INVALID" ->
      Loc_invalid
  | _ ->
      failwith ("Unknown loc " ^ s)

type flag =
  | Nf_explicit
  | Nf_internal
  | Nf_write
  | Nf_callunique
  | Nf_absolute
  | Ti_may_be_in_reg

let string_of_flag = function
  | Nf_explicit ->
      "nf_explicit"
  | Nf_internal ->
      "nf_internal"
  | Nf_write ->
      "nf_write"
  | Ti_may_be_in_reg ->
      "ti_may_be_in_reg"
  | Nf_callunique ->
      "nf_callunique"
  | Nf_absolute ->
      "nf_absolute"

let string_of_flags f =
  "[" ^ String.concat "," (List.map string_of_flag f) ^ "]"

let flag_of_string s =
  match s with
  | "nf_explicit" ->
      Nf_explicit
  | "nf_internal" ->
      Nf_internal
  | "ti_may_be_in_reg" ->
      Ti_may_be_in_reg
  | "nf_write" ->
      Nf_write
  | "nf_callunique" ->
      Nf_callunique
  | "nf_absolute" ->
      Nf_absolute
  | _ ->
      failwith ("Unknown flag " ^ s)

type pt_vtype =
  | Blank
  | Integer of int
  | Str of string
  | ProcFunc of
      ( string (* identifier *)
      * string (* arguments *)
      * string (* Return type *) )
  | List of (string * pt_vtype) list
  | Flags of flag list

let rec string_of_vtype = function
  | Blank ->
      ""
  | Integer i ->
      string_of_int i
  | Str s ->
      s
  | List l ->
      Printf.sprintf "[%s]"
        (String.concat ","
           (List.map (fun i -> fst i ^ " = " ^ string_of_vtype (snd i)) l) )
  | ProcFunc (id, e, rt) ->
      Printf.sprintf "%s(%s)%s%s" id e (if rt = "" then "" else ":") rt
  | Flags f ->
      string_of_flags f

let parse_tree_kv : string -> pt_vtype option = fun _ -> None

let update kvm k v x = if x = k then v else kvm x

let kv_map_of_list =
  List.fold_left
    (fun acc item -> update acc (fst item) (snd item))
    parse_tree_kv

type optional = OString of string | OList of string list

let string_of_optional = function
  | OString s ->
      s
  | OList l ->
      "[" ^ String.concat "," l ^ "]"

let find_data (data : (string * pt_vtype) list) key =
  try snd (List.find (fun s -> fst s = key) data)
  with Not_found -> failwith ("Couldn't find key " ^ key ^ " in data list")

type parse_tree_node =
  { is_func: bool
  ; func_type: return_type_root
  ; pt_type: parse_tree_node_type
  ; label: string
  ; resultdef: return_type
  ; pos: int * int
  ; loc: loc
  ; expectloc: loc
  ; flags: flag list
  ; cmplx: int
  ; optionals: (string * optional) list
  ; data: (string * pt_vtype) list
  ; children: parse_tree_node list }

let rec strn s = function 0 -> "" | n -> s ^ strn s (n - 1)

let rec _string_of_parse_tree indent_lvl t =
  Printf.sprintf
    "%s%s(%s, resultdef = %s, pos = (%d, %d), loc = %s, expectloc = %s, flags \
     = %s, cmplx = %d%s%s%s%s%s)"
    ( if t.is_func then
        string_of_return_type_root t.func_type ^ "\n********************\n"
      else "" )
    (if t.label <> "" then t.label ^ " = " else "")
    (string_of_parse_tree_type t.pt_type)
    (string_of_return_type t.resultdef)
    (fst t.pos) (snd t.pos) (string_of_loc t.loc)
    (string_of_loc t.expectloc)
    (string_of_flags t.flags) t.cmplx
    ( if
        List.length t.children + List.length t.data + List.length t.optionals
        <> 0
      then "\n"
      else "\n" ^ strn "   " (indent_lvl + 1) ^ "nil\n" )
    ( if List.length t.optionals <> 0 then
        String.concat ", "
          (List.map
             (fun i -> fst i ^ " = " ^ string_of_optional (snd i))
             t.optionals )
      else "" )
    ( if List.length t.data <> 0 then
        strn "   " (indent_lvl + 1)
        ^ String.concat
            ("\n" ^ strn "   " (indent_lvl + 1))
            (List.map
               (fun a ->
                 fst a
                 ^ (match snd a with List _ -> "" | _ -> " = ")
                 ^ string_of_vtype (snd a) )
               t.data )
        ^ "\n"
      else "" )
    ( if List.length t.children <> 0 then
        strn "   " (indent_lvl + 1)
        ^ String.concat
            ("\n" ^ strn "   " (indent_lvl + 1))
            (List.map (_string_of_parse_tree (indent_lvl + 1)) t.children)
        ^ "\n"
      else "" )
    (strn "   " indent_lvl)

let string_of_parse_tree = _string_of_parse_tree 0
