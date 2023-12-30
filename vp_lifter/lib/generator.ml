open Converter
open String_utils

let preamble extract extract_lang =
  let coq_extraction_dep s =
    "Extr" ^ String.capitalize_ascii (String.lowercase_ascii extract_lang) ^ s
  in
  let ex =
    if extract then "Extraction Language " ^ extract_lang ^ "." else ""
  in
  let req_imps =
    List.map
      (fun x -> "Require Import " ^ x ^ ".")
      ( remove_empties ["Volpic_preamble"; "String"; "ZArith"; "List"; "Bool"]
      @
      if extract then [coq_extraction_dep "Basic"; coq_extraction_dep "String"]
      else [] )
  in
  let scopes =
    List.map (fun x -> "Open Scope " ^ x ^ ".") ["string_scope"; "Z_scope"]
  in
  let imports = List.map (fun x -> "Import " ^ x ^ ".") ["ListNotations"] in
  String.concat "\n"
    (remove_empties
       (comment "Preamble" :: List.concat [req_imps; [ex]; scopes; imports]) )
  ^ "\n\n"

let lang_ext l =
  match String.lowercase_ascii l with
  | "ocaml" ->
      "ml"
  | "haskell" ->
      "hs"
  | _ ->
      failwith "Unexpected language " ^ l

let extraction fn lang path =
  let path =
    if path = "" then
      String.concat ""
        [Filename.basename (Filename.remove_extension fn); "."; lang_ext lang]
    else path
  in
  String.concat "" ["Extraction \""; path; "\" main."]

type coq_type = Error | Z | String | Unit

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
  | ProcCall _ ->
      Unit
  | Nothing ->
      Unit

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
  | ProcCall (id, e) ->
      String.concat " "
        ( id
        :: remove_empties
             ( store_name
             :: List.map
                  (fun s ->
                    let se = string_of_expr s in
                    if contains se " " then parens se else se )
                  e ) )
  | Nothing ->
      ""

and coq_type_getter e =
  (function
    | Z ->
        "get_int"
    | String ->
        "get_string"
    | Unit ->
        failwith "Shouldn't be calling a getter for unit-type expr "
        ^ string_of_expr e
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
            int_expr_constr
        | ProcCall _ ->
            unit_expr_constr
        | Nothing ->
            failwith "Shouldn't be trying to store a Nothing" )
      ; "("
      ; string_of_expr e
      ; ")" ]
  ^ ")"

let rec string_of_stmt s =
  let f = function
    | Nothing ->
        comment "nothingn statement"
    | Assignment (id, expr) ->
        update_typctx id (type_of_expr expr) ;
        String.concat " "
          ["update"; store_name; stringify id; store_string_of_expr expr]
    | Sequence l ->
        String.concat "\n\t"
          ( comment
              ("Block: next " ^ string_of_int (List.length l) ^ " statements")
            :: List.map string_of_stmt l
          @ [store_name] )
    | SideEffect e ->
        if e = Nothing then ""
        else String.concat " " [letin store_name (string_of_expr e)]
  in
  f s

let rec all_ids_in_expr = function
  | Integer _ | Nothing ->
      []
  | Identifier id ->
      [id]
  | Add (e1, e2) ->
      all_ids_in_expr e1 @ all_ids_in_expr e2
  | ProcCall (_, e) ->
      List.concat (List.map all_ids_in_expr e)

let rec all_ids_in_stmt = function
  | Nothing ->
      []
  | Assignment (_, expr) ->
      all_ids_in_expr expr
  | Sequence l ->
      List.concat (List.map all_ids_in_stmt l)
  | SideEffect expr ->
      all_ids_in_expr expr

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
        ; pair
            (if stmt = Nothing then store_name else string_of_stmt stmt)
            poison
        ; "else"
        ; pair store_name "true" ] ]

let rec _str_of_gal_aux = function
  | Sequence gl ->
      String.concat "\n\t"
        ([letin poison "false"] @ List.map _str_of_gal_aux gl @ [store_name])
  | Statement s ->
      poison_check s

let string_of_gallina g fn extract extract_lang extract_path =
  String.concat "\n"
    (remove_empties
       [ preamble extract extract_lang
       ; String.concat " "
           [definition_str; "main"; "(" ^ store_name ^ " : store)"; ":="]
       ; "\t" ^ _str_of_gal_aux g ^ "."
       ; (if extract then extraction fn extract_lang extract_path else "") ] )
