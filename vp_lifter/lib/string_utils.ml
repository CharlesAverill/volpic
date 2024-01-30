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

let stringify s = "\"" ^ id_prefix ^ s ^ "\""

let pairify l = "(" ^ String.concat "," l ^ ")"

let pair a b = pairify [a; b]

let letin id expr = String.concat " " ["let"; id; ":="; expr; "in"]

let letins ids exprs = letin (pairify ids) (pairify exprs)

let has_parens s =
  String.starts_with ~prefix:"(" s && String.ends_with ~suffix:")" s

let parens s = if has_parens s then s else "(" ^ s ^ ")"

let square_braces s = "[" ^ s ^ "]"

let remove_empties = List.filter (fun s -> s <> "")

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
          Str.search_backward (Str.regexp_string sub) str (String.length str - 1)
          + String.length sub
        with Not_found ->
          failwith ("Couldn't find substring " ^ sub ^ " in string " ^ str) )
  with Not_found ->
    failwith ("Couldn't find substring " ^ sub ^ " in string " ^ str)

let matchwith expr cases =
  String.concat " "
    ( ["match"; parens expr; "with"]
    @ List.map (fun (constr, branch) -> "| " ^ constr ^ " => " ^ branch) cases
    @ ["end"] )

let ifthenelse condition pos neg =
  String.concat " "
    (remove_empties
       [ "if"
       ; parens condition
       ; "then"
       ; parens pos
       ; (if neg <> "" then "else" else "")
       ; (if neg <> "" then parens neg else "") ] )

let matchify e l =
  String.concat " "
    [ "match"
    ; e
    ; "with"
    ; String.concat "| "
        (List.map
           (fun (case, expr) -> String.concat " " [case; "=>"; parens expr])
           l ) ]
