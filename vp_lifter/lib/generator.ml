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

let sanitize_id id =
  let replacements = [("$", "")] in
  let id =
    List.fold_left
      (fun acc (rexp, repl) ->
        Str.global_replace (Str.regexp_string rexp) repl acc )
      id replacements
  in
  if contains id ":" then string_before_substr id ":" else id

let extraction fn lang path =
  let path =
    if path = "" then
      String.concat ""
        [Filename.basename (Filename.remove_extension fn); "."; lang_ext lang]
    else path
  in
  String.concat "" ["Extraction \""; path; "\" main."]

type coq_type = Error | Z | String | Unit | Record | Bool

let string_of_coq_type = function
  | Z ->
      "Z"
  | String ->
      "string"
  | Unit ->
      "unit"
  | Record ->
      "record"
  | Bool ->
      "bool"
  | Error ->
      failwith "Tried to get string of error coq type"

type typ_ctx = id_type -> coq_type

let fresh_gamma _ = Error

let gamma = ref fresh_gamma

let update_typctx id value =
  gamma := fun x -> if x = id then value else !gamma id

let type_of_return_type_root r =
  match r with
  | Dword | LongWord | StrNumber ->
      Z
  | Record _ ->
      Record
  | _ -> 
      failwith ("Haven't set coq type for RTR " ^ string_of_return_type_root r)

(* This returns a string containing the Coq type representation of a variable *)
let type_of_expr = function
  | Identifier id ->
      !gamma id
  | Integer _ | Add _ | Sub _ ->
      Z
  | Gt _ | Lt _ ->
      Bool
  | String _ ->
      String
  | ProcCall _ ->
      Unit
  | FuncCall (_, typ, _) ->
      type_of_return_type_root typ
  | Nothing ->
      Unit

let lcontains l i = List.exists (fun x -> x = i) l

let rec string_of_expr x shallow bound_vars =
  let binop op e1 e2 =
    string_of_expr e1 shallow bound_vars
    ^ " " ^ op ^ " "
    ^ string_of_expr e2 shallow bound_vars
  in
  match x with
  | Identifier id ->
      (* if lcontains bound_vars id then id
         else *)
      String.concat " "
        [ (if shallow then "" else coq_expr_type_getter (Identifier id))
        ; store_name
        ; "\"" ^ id_prefix ^ id ^ "\"" ]
  | Integer n ->
      string_of_int n
  | String s ->
      "\"" ^ s ^ "\""
  | Add (e1, e2) ->
      binop "+" e1 e2
  | Sub (e1, e2) ->
      binop "-" e1 e2
  | Gt (e1, e2) ->
      binop ">?" e1 e2
  | Lt (e1, e2) ->
      binop "<?" e1 e2
  | ProcCall (id, e) ->
      String.concat " "
        ( sanitize_id id
        :: remove_empties
             ( store_name
             :: List.map
                  (fun s ->
                    let se = string_of_expr s shallow bound_vars in
                    if contains se " " then parens se else se )
                  e ) )
  | FuncCall (id, rt, e) ->
      String.concat " "
        (remove_empties
           [ coq_type_getter (type_of_return_type_root rt)
           ; parens
               ( (match rt with Record _ -> "" | _ -> sf_get ^ " ")
               ^ parens
                   (String.concat " "
                      ( sanitize_id id
                      :: remove_empties
                           ( store_name
                           :: List.map
                                (fun s ->
                                  let se =
                                    string_of_expr s shallow bound_vars
                                  in
                                  if contains se " " then parens se else se )
                                e ) ) )
               ^ match rt with Record _ -> "" | _ -> " " ^ stringify "result" )
           ; (match rt with Record _ -> stringify "result" | _ -> "") ] )
  | Nothing ->
      ""

and coq_type_getter = function
  | Z ->
      "get_int"
  | Bool ->
      "get_bool"
  | String ->
      "get_string"
  | Record ->
      ""
  | Unit ->
      failwith "Shouldn't be calling a getter for unit-type expr"
  | Error ->
      failwith "Couldn't retrieve type"

and coq_expr_type_getter e = coq_type_getter (type_of_expr e)

let store_string_of_expr e bound_vars =
  "("
  ^ String.concat " "
      [ ( match e with
        | Identifier id ->
            id_expr_constr
        | Integer _ | Add _ | Sub _ ->
            int_expr_constr
        | Gt _ | Lt _ ->
            bool_expr_constr
        | String _ ->
            str_expr_constr
        | ProcCall _ ->
            unit_expr_constr
        | FuncCall (_, rt, _) -> (
          match rt with
          | Dword ->
              int_expr_constr
          | Record s ->
              comment ("record" ^ s)
          | _ ->
              failwith
                ( "RTR "
                ^ string_of_return_type_root rt
                ^ " not yet supported in store_string_of_expr" ) )
        | Nothing ->
            failwith "Shouldn't be trying to store a Nothing" )
      ; "("
      ; string_of_expr e false bound_vars
      ; ")" ]
  ^ ")"

let rec string_of_stmt (extract : bool) bound_vars s =
  (* TODO : For function calls, clear the 'result' variable after using it *)
  let f : stmt -> string = function
    | Nothing ->
        (* comment "nothingn statement" *) ""
    | Assignment (id, expr) -> (
      match type_of_expr expr with
      | Record ->
          (* Need to find a way to unfold record fields into input variables? Idk *)
          String.concat " "
            [ "update_record"
            ; store_name
            ; stringify id
            ; string_of_expr expr false bound_vars ]
      | _ ->
          update_typctx id (type_of_expr expr) ;
          String.concat " "
            [ "update"
            ; store_name
            ; stringify id
            ; store_string_of_expr expr bound_vars ] )
    | Sequence l ->
        String.concat "\n\t"
          ( comment
              ("Block: next " ^ string_of_int (List.length l) ^ " statements")
            :: remove_empties (List.map (string_of_stmt extract bound_vars) l)
          @ [store_name] )
    | ForLoop (id, el, eh, lb) ->
        (* Check for bound variables *)
        (* Currently, if X is loop iter, lifter will generate (get_int store "VP_X" which is wrong) *)
        update_typctx id Z ;
        let bound_vars = id :: bound_vars in
        String.concat " "
          [ letin "bounds_op"
              ( match (el, eh) with
              | Integer eli, Integer ehi ->
                  if eli < ehi then "Z.leb" else "Z.geb"
              | _ ->
                  failwith "Non-integer loop bounds not yet supported" )
          ; letin store_name
              (String.concat " "
                 [ "update"
                 ; store_name
                 ; stringify id
                 ; store_string_of_expr el bound_vars ] )
          ; parens
              (String.concat " "
                 [ "fix"
                 ; "loop"
                 ; parens (vp_depth ^ " : nat") (* ; parens (id ^ " : Z") *)
                 ; parens (store_name ^ " : store")
                 ; ":="
                 ; matchwith vp_depth
                     [ ("O", "None")
                     ; ( "S n'"
                       , ifthenelse
                           (String.concat " "
                              [ "bounds_op"
                              ; parens
                                  ( coq_expr_type_getter (Identifier id)
                                  ^ " " ^ store_name ^ " " ^ stringify id )
                              ; string_of_expr eh false bound_vars ] )
                           (String.concat " "
                              [ letin store_name
                                  (string_of_stmt extract bound_vars lb)
                              ; letin store_name
                                  (String.concat " "
                                     [ "update"
                                     ; store_name
                                     ; stringify id
                                     ; (let op : expr * expr -> expr =
                                          match (el, eh) with
                                          | Integer eli, Integer ehi ->
                                              fun (e1, e2) ->
                                                if eli < ehi then Add (e1, e2)
                                                else Sub (e1, e2)
                                          | _ ->
                                              failwith
                                                "Non-integer loop bounds not \
                                                 yet supported"
                                        in
                                        parens
                                          (store_string_of_expr
                                             (op (Identifier id, Integer 1))
                                             bound_vars ) ) ] )
                              ; "loop"
                              ; "n'" (* ; parens (id ^ " + 1") *)
                              ; store_name ] )
                           ("Some " ^ store_name) ) ] ] )
          ; "1000%nat"
          ; store_name ]
    | SideEffect e ->
        if e = Nothing then ""
        else
          let content = letin store_name (string_of_expr e false bound_vars) in
          if extract then content else comment content
    | IfThenElse (e, st, sf) ->
        ifthenelse
          (string_of_expr e false bound_vars)
          (string_of_stmt extract bound_vars st)
          ( if sf = Nothing then store_name
            else string_of_stmt extract bound_vars sf )
  in
  f s

(*
   Return all identifiers in an expression
*)
let rec all_ids_in_expr : expr -> string list = function
  | Integer _ | Nothing | String _ ->
      []
  | Identifier id ->
      [id]
  | Add (e1, e2) | Sub (e1, e2) | Gt (e1, e2) | Lt (e1, e2) ->
      all_ids_in_expr e1 @ all_ids_in_expr e2
  | ProcCall (_, e) | FuncCall (_, _, e) ->
      List.concat (List.map all_ids_in_expr e)

(*
   Return all identifiers in a statement
*)
let rec all_ids_in_stmt : stmt -> string list = function
  | Nothing ->
      []
  | Assignment (_, expr) ->
      all_ids_in_expr expr
  | Sequence l ->
      List.concat (List.map all_ids_in_stmt l)
  | SideEffect expr ->
      all_ids_in_expr expr
  | ForLoop (_, el, eh, lb) ->
      all_ids_in_expr el @ all_ids_in_expr eh @ all_ids_in_stmt lb
  | IfThenElse (expr, st, sf) ->
      all_ids_in_expr expr @ all_ids_in_stmt st @ all_ids_in_stmt sf

let runtime_check = function ForLoop _ -> true | _ -> false

(*
   Wrapper for string_of_stmt that adds a "poison check," essentially capturing
   runtime errors, including:

   - Undefined variable (not a runtime error, added for practice)
*)
let poison_check stmt (extract : bool) bound_vars =
  (* TODO : For all stores in a statement, ensure that
     if the ident already exists, the type of its new value
     matches the type of its old value. If not, poisoned.
  *)
  letins [store_name; poison]
    [ ifthenelse
        (String.concat " "
           [ "multi_ands"
           ; square_braces
               (String.concat " "
                  [ "negb"
                  ; poison
                    (*";"
                      ; "all_in_ids"
                         ; store_name
                           ; square_braces
                               (String.concat ";"
                                  (List.map
                                     (fun x -> stringify x)
                                     (all_ids_in_stmt stmt) ) ) *) ] ) ] )
        ( if runtime_check stmt then
            String.concat " "
              [ matchwith
                  (string_of_stmt extract bound_vars stmt)
                  [ ("None", pair store_name "true")
                  ; ("Some " ^ store_name ^ "'", pair (store_name ^ "'") poison)
                  ] ]
          else
            pair
              ( if stmt = Nothing then store_name
                else string_of_stmt extract bound_vars stmt )
              poison )
        (pair store_name "true") ]

(* Generate function/procedure definitions *)
let rec _str_of_gal_aux (extract : bool) bound_vars = function
  (* TODO : For functions, return should be original passed-in store with result var set,
     should naturally handle function scopes *)
  | Root (pt, gal) ->
      ( match pt.func_type with
      | Procedure (id, rtl) ->
          String.concat " "
            ( [definition_str; sanitize_id id; "(" ^ store_name ^ ": store)"]
            @ List.mapi
                (fun i rt ->
                  let t = match rt with RT n | Const n -> n | Var n -> n in
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
            ( [definition_str; sanitize_id id; "(" ^ store_name ^ ": store)"]
            @ List.mapi
                (fun i rt ->
                  let t = match rt with RT n | Const n -> n | Var n -> n in
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
      ^ _str_of_gal_aux extract bound_vars gal
  | Sequence gl ->
      String.concat "\n\t"
        ( [letin poison "false"]
        @ List.map (_str_of_gal_aux extract bound_vars) gl
        @ [store_name] )
  | Statement s ->
      poison_check s extract bound_vars
  | Comment s ->
      comment s

(* Entry function *)
let string_of_gallina do_preamble fn extract extract_lang extract_path func_name
    g =
  String.concat "\n"
    (remove_empties
       [ (if do_preamble then preamble extract extract_lang else "")
       ; _str_of_gal_aux extract [] g ^ "."
       ; (if extract then extraction fn extract_lang extract_path else "") ] )
  ^ "\n"
