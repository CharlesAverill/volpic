open String_utils

type parse_tree_node_type =
  | Emptynode
  | Add
  | Mul
  | Sub
  | Div
  | Symdif
  | Mod
  | Assign
  | Load
  | Range
  | Lt
  | Lte
  | Gt
  | Gte
  | Equal
  | Unequal
  | In
  | Or
  | Xor
  | Shr
  | Shl
  | Slash
  | And
  | Subscript
  | Deref
  | Addr
  | Ordconst
  | Typeconv
  | Call
  | Callpara
  | Realconst
  | Unaryminus
  | Unaryplus
  | Asm
  | Vec
  | Pointerconst
  | Stringconst
  | Not
  | Inline
  | Nil
  | Error
  | Type
  | Setelement
  | Setconst
  | Block
  | Statement
  | If
  | Break
  | Continue
  | Whilerepeat
  | For
  | Exit
  | Case
  | Label
  | Goto
  | Tryexcept
  | Raise
  | Tryfinally
  | On
  | Is
  | As
  | Starstar
  | Arrayconstruct
  | Arrayconstructrange
  | Tempcreate
  | Tempref
  | Tempdelete
  | Addopt
  | Nothing
  | Loadvmtaddr
  | Guidconst
  | Rtti
  | Loadparentfp
  | Objcselector
  | Objcprotocol
  | Specialize
  | Finalizetemps

let string_of_parse_tree_type = function
  | Emptynode ->
      "<emptynode>"
  | Add ->
      "addn"
  | Mul ->
      "muln"
  | Sub ->
      "subn"
  | Div ->
      "divn"
  | Symdif ->
      "symdifn"
  | Mod ->
      "modn"
  | Assign ->
      "assignn"
  | Load ->
      "loadn"
  | Range ->
      "rangen"
  | Lt ->
      "ltn"
  | Lte ->
      "lten"
  | Gt ->
      "gtn"
  | Gte ->
      "gten"
  | Equal ->
      "equaln"
  | Unequal ->
      "unequaln"
  | In ->
      "inn"
  | Or ->
      "orn"
  | Xor ->
      "xorn"
  | Shr ->
      "shrn"
  | Shl ->
      "shln"
  | Slash ->
      "slashn"
  | And ->
      "andn"
  | Subscript ->
      "subscriptn"
  | Deref ->
      "derefn"
  | Addr ->
      "addrn"
  | Ordconst ->
      "ordconstn"
  | Typeconv ->
      "typeconvn"
  | Call ->
      "calln"
  | Callpara ->
      "callparan"
  | Realconst ->
      "realconstn"
  | Unaryminus ->
      "unaryminusn"
  | Unaryplus ->
      "unaryplusn"
  | Asm ->
      "asmn"
  | Vec ->
      "vecn"
  | Pointerconst ->
      "pointerconstn"
  | Stringconst ->
      "stringconstn"
  | Not ->
      "notn"
  | Inline ->
      "inlinen"
  | Nil ->
      "niln"
  | Error ->
      "errorn"
  | Type ->
      "typen"
  | Setelement ->
      "setelementn"
  | Setconst ->
      "setconstn"
  | Block ->
      "blockn"
  | Statement ->
      "statementn"
  | If ->
      "ifn"
  | Break ->
      "breakn"
  | Continue ->
      "continuen"
  | Whilerepeat ->
      "whilerepeatn"
  | For ->
      "forn"
  | Exit ->
      "exitn"
  | Case ->
      "casen"
  | Label ->
      "labeln"
  | Goto ->
      "goton"
  | Tryexcept ->
      "tryexceptn"
  | Raise ->
      "raisen"
  | Tryfinally ->
      "tryfinallyn"
  | On ->
      "onn"
  | Is ->
      "isn"
  | As ->
      "asn"
  | Starstar ->
      "starstarn"
  | Arrayconstruct ->
      "arrayconstructn"
  | Arrayconstructrange ->
      "arrayconstructrangen"
  | Tempcreate ->
      "tempcreaten"
  | Tempref ->
      "temprefn"
  | Tempdelete ->
      "tempdeleten"
  | Addopt ->
      "addoptn"
  | Nothing ->
      "nothingn"
  | Loadvmtaddr ->
      "loadvmtaddrn"
  | Guidconst ->
      "guidconstn"
  | Rtti ->
      "rttin"
  | Loadparentfp ->
      "loadparentfpn"
  | Objcselector ->
      "objcselectorn"
  | Objcprotocol ->
      "objcprotocoln"
  | Specialize ->
      "specializen"
  | Finalizetemps ->
      "finalizetempsn"

type range = Unbounded | Range of (int * int)

let string_of_range = function
  | Unbounded ->
      ""
  | Range (a, b) ->
      "[" ^ string_of_int a ^ ".." ^ string_of_int b ^ "]"

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

let rtr_of_rt = function RT rtr | Const rtr | Var rtr -> rtr

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
      print_endline (id ^ " is a procedure") ;
      id
      ^
      if List.length args <> 0 then
        "(" ^ String.concat ";" (List.map string_of_return_type args) ^ ")"
      else ";"
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
  print_endline "WHAT" ;
  print_endline s ;
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
        , List.map return_type_of_string
            (remove_empties
               (String.split_on_char ';'
                  (string_after_substr (string_before_substr s ")") "(") ) )
        , return_type_of_string
            (string_before_substr (string_after_substr s ":") ";") )
    else
      Procedure
        ( string_before_substr s "("
        , List.map return_type_of_string
            (remove_empties
               (String.split_on_char ';'
                  (string_after_substr (string_before_substr s ")") "(") ) ) )
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
    | "int_arr" ->
        Array (false, Unbounded, Int64)
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
  | Nf_swapable
  | Nf_swapped
  | Nf_error
  | Nf_pass1_done
  | Nf_write
  | Nf_modify
  | Nf_address_taken
  | Nf_is_funcret
  | Nf_isproperty
  | Nf_processing
  | Nf_no_lvalue
  | Nf_usercode_entry
  | Nf_no_checkpointer
  | Nf_memindex
  | Nf_memseg
  | Nf_callunique
  | Nf_absolute
  | Nf_is_currency
  | Nf_has_pointerdiv
  | Nf_short_bool
  | Nf_isomod
  | Nf_assign_done_in_right
  | Nf_forcevaria
  | Nf_novariaallowed
  | Nf_explicit
  | Nf_internal
  | Nf_load_procvar
  | Nf_inlineconst
  | Nf_get_asm_position
  | Nf_block_with_exit
  | Nf_ignore_for_wpo
  | Nf_generic_para
  | Nf_do_not_execute
  | Ti_may_be_in_reg
  | Ti_addr_taken
  | Ti_reference
  | Ti_readonly
  | Ti_no_final_regsync
  | Ti_nofini
  | Ti_const

let string_of_flag = function
  | Nf_swapable ->
      "nf_swapable"
  | Nf_swapped ->
      "nf_swapped"
  | Nf_error ->
      "nf_error"
  | Nf_pass1_done ->
      "nf_pass1_done"
  | Nf_write ->
      "nf_write"
  | Nf_modify ->
      "nf_modify"
  | Nf_address_taken ->
      "nf_address_taken"
  | Nf_is_funcret ->
      "nf_is_funcret"
  | Nf_isproperty ->
      "nf_isproperty"
  | Nf_processing ->
      "nf_processing"
  | Nf_no_lvalue ->
      "nf_no_lvalue"
  | Nf_usercode_entry ->
      "nf_usercode_entry"
  | Nf_no_checkpointer ->
      "nf_no_checkpointer"
  | Nf_memindex ->
      "nf_memindex"
  | Nf_memseg ->
      "nf_memseg"
  | Nf_callunique ->
      "nf_callunique"
  | Nf_absolute ->
      "nf_absolute"
  | Nf_is_currency ->
      "nf_is_currency"
  | Nf_has_pointerdiv ->
      "nf_has_pointerdiv"
  | Nf_short_bool ->
      "nf_short_bool"
  | Nf_isomod ->
      "nf_isomod"
  | Nf_assign_done_in_right ->
      "nf_assign_done_in_right"
  | Nf_forcevaria ->
      "nf_forcevaria"
  | Nf_novariaallowed ->
      "nf_novariaallowed"
  | Nf_explicit ->
      "nf_explicit"
  | Nf_internal ->
      "nf_internal"
  | Nf_load_procvar ->
      "nf_load_procvar"
  | Nf_inlineconst ->
      "nf_inlineconst"
  | Nf_get_asm_position ->
      "nf_get_asm_position"
  | Nf_block_with_exit ->
      "nf_block_with_exit"
  | Nf_ignore_for_wpo ->
      "nf_ignore_for_wpo"
  | Nf_generic_para ->
      "nf_generic_para"
  | Nf_do_not_execute ->
      "nf_do_not_execute"
  | Ti_may_be_in_reg ->
      "ti_may_be_in_reg"
  | Ti_addr_taken ->
      "ti_addr_taken"
  | Ti_reference ->
      "ti_reference"
  | Ti_readonly ->
      "ti_readonly"
  | Ti_no_final_regsync ->
      "ti_no_final_regsync"
  | Ti_nofini ->
      "ti_nofini"
  | Ti_const ->
      "ti_const"

let string_of_flags f =
  "[" ^ String.concat "," (List.map string_of_flag f) ^ "]"

let flag_of_string s =
  match s with
  | "nf_swapable" ->
      Nf_swapable
  | "nf_swapped" ->
      Nf_swapped
  | "nf_error" ->
      Nf_error
  | "nf_pass1_done" ->
      Nf_pass1_done
  | "nf_write" ->
      Nf_write
  | "nf_modify" ->
      Nf_modify
  | "nf_address_taken" ->
      Nf_address_taken
  | "nf_is_funcret" ->
      Nf_is_funcret
  | "nf_isproperty" ->
      Nf_isproperty
  | "nf_processing" ->
      Nf_processing
  | "nf_no_lvalue" ->
      Nf_no_lvalue
  | "nf_usercode_entry" ->
      Nf_usercode_entry
  | "nf_no_checkpointer" ->
      Nf_no_checkpointer
  | "nf_memindex" ->
      Nf_memindex
  | "nf_memseg" ->
      Nf_memseg
  | "nf_callunique" ->
      Nf_callunique
  | "nf_absolute" ->
      Nf_absolute
  | "nf_is_currency" ->
      Nf_is_currency
  | "nf_has_pointerdiv" ->
      Nf_has_pointerdiv
  | "nf_short_bool" ->
      Nf_short_bool
  | "nf_isomod" ->
      Nf_isomod
  | "nf_assign_done_in_right" ->
      Nf_assign_done_in_right
  | "nf_forcevaria" ->
      Nf_forcevaria
  | "nf_novariaallowed" ->
      Nf_novariaallowed
  | "nf_explicit" ->
      Nf_explicit
  | "nf_internal" ->
      Nf_internal
  | "nf_load_procvar" ->
      Nf_load_procvar
  | "nf_inlineconst" ->
      Nf_inlineconst
  | "nf_get_asm_position" ->
      Nf_get_asm_position
  | "nf_block_with_exit" ->
      Nf_block_with_exit
  | "nf_ignore_for_wpo" ->
      Nf_ignore_for_wpo
  | "nf_generic_para" ->
      Nf_generic_para
  | "nf_do_not_execute" ->
      Nf_do_not_execute
  | "ti_may_be_in_reg" ->
      Ti_may_be_in_reg
  | "ti_addr_taken" ->
      Ti_addr_taken
  | "ti_reference" ->
      Ti_reference
  | "ti_readonly" ->
      Ti_readonly
  | "ti_no_final_regsync" ->
      Ti_no_final_regsync
  | "ti_nofini" ->
      Ti_nofini
  | "ti_const" ->
      Ti_const
  | _ ->
      failwith ("Unknown flag " ^ s)

type pt_vtype =
  | Blank
  | Integer of int
  | Float of float
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
  | Float f ->
      string_of_float f
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
