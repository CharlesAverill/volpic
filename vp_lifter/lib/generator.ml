open Converter
open String_utils

let preamble =
  let req_imps =
    List.map
      (fun x -> "Require Import " ^ x ^ ".")
      ["Volpic_preamble"; "String"; "ZArith"; "List"; "Bool"]
  in
  let scopes =
    List.map (fun x -> "Open Scope " ^ x ^ ".") ["string_scope"; "Z_scope"]
  in
  let imports = List.map (fun x -> "Import " ^ x ^ ".") ["ListNotations"] in
  String.concat "\n"
    (comment "Preamble" :: List.concat [req_imps; scopes; imports])
  ^ "\n\n"

type coq_type = Error | Z | String

type typ_ctx = id_type -> coq_type

let fresh_gamma _ = Error

let gamma = ref fresh_gamma

let update_typctx id value =
  gamma := fun x -> if x = id then value else !gamma id

(* This returns a string containing the Coq type representation of a variable *)
let type_of_expr = function
  | Identifier id ->
      !gamma id
  | Integer _ | Add _ ->
      Z

let rec string_of_expr = function
  | Identifier id ->
      String.concat " "
        [ coq_type_getter (Identifier id)
        ; store_name
        ; "\"" ^ id_prefix ^ id ^ "\"" ]
  | Integer n ->
      string_of_int n
  | Add (e1, e2) ->
      string_of_expr e1 ^ " + " ^ string_of_expr e2

and coq_type_getter e =
  (function
    | Z ->
        "get_int"
    | String ->
        "get_string"
    | Error ->
        failwith "Couldn't retrieve type for expr " ^ string_of_expr e )
    (type_of_expr e)

let store_string_of_expr e =
  "("
  ^ String.concat " "
      [ ( match e with
        | Identifier id ->
            id_expr_constr
        | Integer _ | Add _ ->
            int_expr_constr )
      ; "("
      ; string_of_expr e
      ; ")" ]
  ^ ")"

let string_of_stmt s =
  let f = function
    | Assignment (id, expr) ->
        update_typctx id (type_of_expr expr) ;
        String.concat " "
          ["update"; store_name; stringify id; store_string_of_expr expr]
  in
  f s

let rec all_ids_in_expr = function
  | Integer _ ->
      []
  | Identifier id ->
      [id]
  | Add (e1, e2) ->
      all_ids_in_expr e1 @ all_ids_in_expr e2

let all_ids_in_stmt = function Assignment (_, expr) -> all_ids_in_expr expr

let poison_check stmt =
  letins [store_name; poison]
    [ String.concat " "
        [ "if"
        ; "("
        ; "andb"
        ; "("
        ; "negb"
        ; poison
        ; ")"
        ; "("
        ; "all_in_ids"
        ; store_name
        ; "["
        ; String.concat ";"
            (List.map (fun x -> stringify x) (all_ids_in_stmt stmt))
        ; "]"
        ; ")"
        ; ")"
        ; "then"
        ; pair (string_of_stmt stmt) poison
        ; "else"
        ; pair store_name "true" ] ]

let rec _str_of_gal_aux = function
  | Sequence gl ->
      String.concat "\n\t"
        ([letin poison "false"] @ List.map _str_of_gal_aux gl @ [store_name])
  | Statement s ->
      poison_check s

let string_of_gallina g =
  preamble
  ^ String.concat " "
      [definition_str; "main"; "(" ^ store_name ^ " : store)"; ":="; "\n\t"]
  ^ _str_of_gal_aux g ^ "."
