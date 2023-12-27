open Converter

let definition_str = "Definition"

let id_prefix = "VOLPIC_"

let store_name = id_prefix ^ "store"

let id_expr_constr = "Identifier"

and int_expr_constr = "Integer"

let preamble =
  "From Volpic Require Import Volpic_preamble.\n\
   Require Import String.\n\
   Open Scope string_scope.\n"

let stringify s = "\"" ^ s ^ "\""

let string_of_expr = function
  | Identifier id ->
      "(" ^ String.concat " " [id_expr_constr; id_prefix ^ id] ^ ")"
  | Integer n ->
      "(" ^ String.concat " " [int_expr_constr; string_of_int n] ^ ")"

let string_of_stmt s =
  let f = function
    | Assignment (id, expr) ->
        String.concat " "
          ["update"; store_name; stringify id; string_of_expr expr]
  in
  "let " ^ store_name ^ " := " ^ f s ^ " in"

let rec _str_of_gal_aux = function
  | Sequence gl ->
      String.concat "\n\t" (List.map _str_of_gal_aux gl @ [store_name])
  | Statement s ->
      string_of_stmt s

let string_of_gallina g =
  preamble
  ^ String.concat " "
      [definition_str; "main"; "(" ^ store_name ^ " : store)"; ":="; "\n\t"]
  ^ _str_of_gal_aux g ^ "."
