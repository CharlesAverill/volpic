open Converter
open String_utils
open Parse_tree

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

let string_of_coq_type = function
  | Z ->
      "Z"
  | String ->
      "string"
  | Unit ->
      "unit"
  | Error ->
      failwith "Tried to get string of error coq type"

type typ_ctx = id_type -> coq_type

let fresh_gamma _ = Error

let gamma = ref fresh_gamma

let update_typctx id value =
  gamma := fun x -> if x = id then value else !gamma id

let type_of_return_type_root r =
  match r with
  | Dword | LongWord ->
      Z
  | _ ->
      failwith ("Haven't set coq type for RTR " ^ string_of_return_type_root r)

(* This returns a string containing the Coq type representation of a variable *)
let type_of_expr = function
  | Identifier id ->
      !gamma id
  | Integer _ | Add _ | Sub _ ->
      Z
  | ProcCall _ ->
      Unit
  | FuncCall (_, typ, _) ->
      type_of_return_type_root typ
  | Nothing ->
      Unit

let rec string_of_expr x shallow =
  let binop op e1 e2 =
    string_of_expr e1 shallow ^ " " ^ op ^ " " ^ string_of_expr e2 shallow
  in
  match x with
  | Identifier id ->
      String.concat " "
        [ (if shallow then "" else coq_expr_type_getter (Identifier id))
        ; store_name
        ; "\"" ^ id_prefix ^ id ^ "\"" ]
  | Integer n ->
      string_of_int n
  | Add (e1, e2) ->
      binop "+" e1 e2
  | Sub (e1, e2) ->
      binop "-" e1 e2
  | ProcCall (id, e) ->
      String.concat " "
        ( id
        :: remove_empties
             ( store_name
             :: List.map
                  (fun s ->
                    let se = string_of_expr s shallow in
                    if contains se " " then parens se else se )
                  e ) )
  | FuncCall (id, rt, e) ->
      String.concat " "
        [ coq_type_getter (type_of_return_type_root rt)
        ; parens
            (String.concat " "
               ( id
               :: remove_empties
                    ( store_name
                    :: List.map
                         (fun s ->
                           let se = string_of_expr s shallow in
                           if contains se " " then parens se else se )
                         e ) ) )
        ; stringify "result" ]
  | Nothing ->
      ""

and coq_type_getter = function
  | Z ->
      "get_int"
  | String ->
      "get_string"
  | Unit ->
      failwith "Shouldn't be calling a getter for unit-type expr"
  | Error ->
      failwith "Couldn't retrieve type"

and coq_expr_type_getter e = coq_type_getter (type_of_expr e)

let store_string_of_expr e =
  "("
  ^ String.concat " "
      [ ( match e with
        | Identifier id ->
            id_expr_constr
        | Integer _ | Add _ | Sub _ ->
            int_expr_constr
        | ProcCall _ ->
            unit_expr_constr
        | FuncCall (_, rt, _) -> (
          match rt with
          | Dword ->
              int_expr_constr
          | _ ->
              failwith
                ( "RTR "
                ^ string_of_return_type_root rt
                ^ " not yet supported in store_string_of_expr" ) )
        | Nothing ->
            failwith "Shouldn't be trying to store a Nothing" )
      ; "("
      ; string_of_expr e false
      ; ")" ]
  ^ ")"

let rec string_of_stmt extract s =
  let f : stmt -> string = function
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
            :: List.map (string_of_stmt extract) l
          @ [store_name] )
    | SideEffect e ->
        if e = Nothing then ""
        else
          let content = letin store_name (string_of_expr e false) in
          if extract then content else comment content
  in
  f s

let rec all_ids_in_expr : expr -> string list = function
  | Integer _ | Nothing ->
      []
  | Identifier id ->
      [id]
  | Add (e1, e2) ->
      all_ids_in_expr e1 @ all_ids_in_expr e2
  | Sub (e1, e2) ->
      all_ids_in_expr e1 @ all_ids_in_expr e2
  | ProcCall (_, e) ->
      List.concat (List.map all_ids_in_expr e)
  | FuncCall (_, _, e) ->
      List.concat (List.map all_ids_in_expr e)

let rec all_ids_in_stmt : stmt -> string list = function
  | Nothing ->
      []
  | Assignment (_, expr) ->
      all_ids_in_expr expr
  | Sequence l ->
      List.concat (List.map all_ids_in_stmt l)
  | SideEffect expr ->
      all_ids_in_expr expr

let poison_check stmt extract =
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
            (if stmt = Nothing then store_name else string_of_stmt extract stmt)
            poison
        ; "else"
        ; pair store_name "true" ] ]

let rec _str_of_gal_aux extract = function
  | Root (pt, gal) ->
      ( match pt.func_type with
      | Procedure (id, rtl) ->
          String.concat " "
            ( [definition_str; id; "(" ^ store_name ^ ": store)"]
            @ List.mapi
                (fun i rt ->
                  let t = match rt with RT n | Const n -> n in
                  String.concat " "
                    [ "("
                    ; "arg" ^ string_of_int i
                    ; ":"
                    ; string_of_coq_type (type_of_return_type_root t)
                    ; ")" ] )
                rtl
            @ [":="; "\n\t"] )
      | Function (id, rtl, rt) ->
          String.concat " "
            ( [definition_str; id; "(" ^ store_name ^ ": store)"]
            @ List.mapi
                (fun i rt ->
                  let t = match rt with RT n | Const n -> n in
                  String.concat " "
                    [ "("
                    ; "arg" ^ string_of_int i
                    ; ":"
                    ; string_of_coq_type (type_of_return_type_root t)
                    ; ")" ] )
                rtl
            @ [":="; "\n\t"] )
      | _ ->
          failwith "Expected procedure or function as root node" )
      ^ _str_of_gal_aux extract gal
  | Sequence gl ->
      String.concat "\n\t"
        ( [letin poison "false"]
        @ List.map (_str_of_gal_aux extract) gl
        @ [store_name] )
  | Statement s ->
      poison_check s extract

let string_of_gallina do_preamble fn extract extract_lang extract_path func_name
    g =
  String.concat "\n"
    (remove_empties
       [ (if do_preamble then preamble extract extract_lang else "")
       ; _str_of_gal_aux extract g ^ "."
       ; (if extract then extraction fn extract_lang extract_path else "") ] )
  ^ "\n"
