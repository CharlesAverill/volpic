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

type return_type =
  | Nil
  | Pointer of return_type
  | Untyped
  | Dword
  | Qword
  | Text
  | LongInt
  | ShortString

let rec string_of_return_type = function
  | Nil ->
      "nil"
  | Pointer rt' ->
      "^" ^ string_of_return_type rt'
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

let rec return_type_of_string s =
  if String.get s 0 = '^' then
    Pointer (return_type_of_string (String.sub s 1 (String.length s - 1)))
  else
    match String.lowercase_ascii s with
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
    | _ ->
        failwith ("Unknown return type " ^ s)

type loc = Loc_invalid

let string_of_loc = function Loc_invalid -> "LOC_INVALID"

let loc_of_string s =
  match s with
  | "LOC_INVALID" ->
      Loc_invalid
  | _ ->
      failwith ("Unknown loc " ^ s)

type flag = Nf_explicit | Nf_internal | Nf_write | Ti_may_be_in_reg

let string_of_flag = function
  | Nf_explicit ->
      "nf_explicit"
  | Nf_internal ->
      "nf_internal"
  | Nf_write ->
      "nf_write"
  | Ti_may_be_in_reg ->
      "ti_may_be_in_reg"

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
  | _ ->
      failwith ("Unknown flag " ^ s)

type pt_vtype =
  | Blank
  | Integer of int
  | String of string
  | List of (string * pt_vtype) list
  | Flags of flag list

let rec string_of_vtype = function
  | Blank ->
      ""
  | Integer i ->
      string_of_int i
  | String s ->
      s
  | List l ->
      Printf.sprintf "[%s]"
        (String.concat ","
           (List.map (fun i -> fst i ^ " = " ^ string_of_vtype (snd i)) l) )
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

type parse_tree_node =
  { pt_type: parse_tree_node_type
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
    "(%s, resultdef = %s, pos = (%d, %d), loc = %s, expectloc = %s, flags = \
     %s, cmplx = %d%s%s%s%s%s)"
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
