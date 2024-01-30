open String

type string = t

let definition_str = "Definition"

let id_prefix = "VP_"

let store_name = id_prefix ^ "store"

let vp_depth = id_prefix ^ "depth"

let vp_preamble = "Volpic_preamble"

let fresh_store = "fresh_store"

let id_expr_constr = "Identifier"

let int_expr_constr = "VInteger"

let bool_expr_constr = "VBool"

let str_expr_constr = "VString"

let unit_expr_constr = "VUnit"

let poison = id_prefix ^ "poison"

let broken = id_prefix ^ "broken"

let sf_get = "sf_get"

let comment s = "(*" ^ s ^ "*)"

let enforce_endswith_store s =
  if ends_with s ~suffix:store_name then s
  else if ends_with s ~suffix:" in" then s ^ " " ^ store_name
  else if ends_with s ~suffix:" in)" then
    sub s 0 (length s - 4) ^ " " ^ store_name ^ ")"
  else s
(* failwith
   ( "Couldn't enforce endswith_store for string:\n==========" ^ s
   ^ "\n==========" ) *)

let tabs n = make n '\t'

let has_parens s = starts_with ~prefix:"(" s && ends_with ~suffix:")" s

let parens ?(parens_req_spaces = true) s =
  if has_parens s || ((not (contains s ' ')) && parens_req_spaces) then s
  else "(" ^ trim s ^ ")"

let stringify s = "\"" ^ id_prefix ^ s ^ "\""

let pairify l = parens ~parens_req_spaces:false (concat "," l)

let pair a b = pairify [a; b]

let square_braces s = "[" ^ s ^ "]"

let remove_empties = List.filter (fun s -> s <> "")

let econcat sep l = concat sep (remove_empties l)

let letin depth id expr = tabs depth ^ econcat " " ["let"; id; ":="; expr; "in"]

let letins depth ids exprs =
  letin depth (pairify ids) ("\n" ^ tabs (depth + 1) ^ pairify exprs)

let contains s1 s2 =
  let re = Str.regexp_string s2 in
  try
    ignore (Str.search_forward re s1 0) ;
    true
  with Not_found -> false

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
          Str.search_backward (Str.regexp_string sub) str (length str - 1)
          + length sub
        with Not_found ->
          failwith ("Couldn't find substring " ^ sub ^ " in string " ^ str) )
  with Not_found ->
    failwith ("Couldn't find substring " ^ sub ^ " in string " ^ str)

let matchwith ?(noindent_first = false) depth expr cases =
  econcat " "
    ( [ (if noindent_first then "" else tabs depth)
      ; "match"
      ; (if contains expr "\n" then "\n" else "") ^ parens expr
      ; "with"
      ; "\n"
      ; tabs (depth + 1) ]
    @ List.map
        (fun (constr, branch) ->
          "| " ^ trim constr ^ " => " ^ trim branch ^ "\n" ^ tabs (depth + 1) )
        cases
    @ [tabs depth; "end"] )

let ifthenelse ?(noindent_first = false) ?(one_line = false) depth condition pos
    neg =
  if neg = "" then failwith "If expressions must be total"
  else
    let depth = if one_line then 0 else depth in
    let newline = if one_line then "" else "\n" in
    let itabs = if one_line then "" else tabs (depth + 1) in
    econcat " "
      (remove_empties
         [ (if noindent_first then "" else tabs depth)
         ; "if"
         ; parens condition
         ; "then" ^ newline
         ; itabs
         ; parens (trim pos)
         ; newline ^ tabs depth ^ "else" ^ newline
         ; itabs ^ parens (trim neg) ] )
