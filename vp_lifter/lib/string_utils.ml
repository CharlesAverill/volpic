let definition_str = "Definition"

let id_prefix = "VP_"

let store_name = id_prefix ^ "store"

let id_expr_constr = "Identifier"

let int_expr_constr = "Integer"

let poison = id_prefix ^ "poison"

let comment s = "(*" ^ s ^ "*)"

let stringify s = "\"" ^ id_prefix ^ s ^ "\""

let pairify l = "(" ^ String.concat "," l ^ ")"

let pair a b = pairify [a; b]

let letin id expr = String.concat " " ["let"; id; ":="; expr; "in"]

let letins ids exprs = letin (pairify ids) (pairify exprs)
