open Converter
open String_utils
open Parse_tree
open Logging

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
      ( ["Volpic_preamble"; "String"; "ZArith"; "List"; "Bool"]
      @
      if extract then [coq_extraction_dep "Basic"; coq_extraction_dep "String"]
      else [] )
  in
  let scopes =
    List.map
      (fun x -> "Open Scope " ^ x ^ ".")
      ["string_scope"; "Z_scope"; "vp_scope"]
  in
  let imports = List.map (fun x -> "Import " ^ x ^ ".") ["ListNotations"] in
  econcat "\n"
    (comment "Preamble" :: List.concat [req_imps; [ex]; scopes; imports])
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

let extraction fn func lang path =
  let path =
    if path = "" then
      econcat ""
        [Filename.basename (Filename.remove_extension fn); "."; lang_ext lang]
    else path
  in
  econcat " " ["Extraction"; "\"" ^ path ^ "\""; func ^ "."]

let typctx = ref fresh_gamma

(* This returns a string containing the Coq type representation of a variable *)
let type_of_expr = function
  | Identifier id ->
      _log Log_Debug
        ("Getting type of " ^ id ^ ": " ^ string_of_coq_type (!typctx id)) ;
      !typctx id
  | Integer _ | Add _ | Sub _ ->
      Z
  | Gt _ | Lt _ | Eq _ ->
      Bool
  | String _ ->
      String
  | ProcCall _ ->
      Unit
  | FuncCall (_, typ, _) ->
      coq_type_of_return_type_root typ
  | Subscript (rtr, _, _) ->
      coq_type_of_return_type_root (rtr_of_rt rtr)
  | Nothing ->
      Unit

let lcontains l i = List.exists (fun x -> x = i) l

let default_coq_value = function
  | Z ->
      parens (econcat " " [int_expr_constr; "0"])
  | _ ->
      "VNull"

let constr_of_coq_type = function
  | Z ->
      int_expr_constr
  | String ->
      str_expr_constr
  | Unit ->
      failwith "Shouldn't be trying to store a unit"
  | Record ->
      failwith "Can't store records yet"
  | Bool ->
      bool_expr_constr
  | Vector _ ->
      failwith "Can't store vectors yet"
  | Error ->
      failwith "Shouldn't be trying to store an error"

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
      econcat " "
        [ (* (if shallow then "" else coq_expr_type_getter (Identifier id))
             ; *)
          sf_get
        ; store_name
        ; "\"" ^ id_prefix ^ id ^ "\"" ]
  | Subscript (rt, arr, idx) ->
      econcat " "
        [ "subscript"
        ; parens (string_of_expr arr shallow bound_vars)
        ; parens (string_of_expr idx shallow bound_vars)
        ; default_coq_value (coq_type_of_return_type_root (rtr_of_rt rt)) ]
  | Integer n ->
      constr_of_coq_type Z ^ " " ^ string_of_int n
  | String s ->
      constr_of_coq_type String ^ " \"" ^ s ^ "\""
  | Add (e1, e2) ->
      binop "+" e1 e2
  | Sub (e1, e2) ->
      binop "-" e1 e2
  | Gt (e1, e2) ->
      binop ">?" e1 e2
  | Lt (e1, e2) ->
      binop "<?" e1 e2
  | Eq (e1, e2) ->
      binop "=?" e1 e2
  | ProcCall (id, e) ->
      econcat " "
        ( sanitize_id id :: store_name
        :: List.map
             (fun s ->
               let se = string_of_expr s shallow bound_vars in
               if contains se " " then parens se else se )
             e )
  | FuncCall (func_name, rt, e) ->
      econcat " "
        [ (* coq_type_getter (coq_type_of_return_type_root rt)
             ; *)
          ( (* (match rt with Record _ -> "" | _ -> sf_get ^ " ")
                 ^ *)
            parens
              (econcat " "
                 ( sanitize_id func_name :: store_name
                 :: List.map
                      (fun s ->
                        let se = string_of_expr s shallow bound_vars in
                        if contains se " " then parens se else se )
                      e ) )
          ^ match rt with Record _ -> "" | _ -> " " ^ stringify "result" )
        ; (match rt with Record _ -> stringify "result" | _ -> "") ]
  | Nothing ->
      ""

and coq_type_getter = function
  | Z ->
      "get_int"
  | Bool ->
      "get_bool"
  | String ->
      "get_string"
  | Vector s ->
      "get_array"
  | Record ->
      ""
  | Unit ->
      failwith "Shouldn't be calling a getter for unit-type expr"
  | Error ->
      failwith "Couldn't retrieve type"

and coq_expr_type_getter e = coq_type_getter (type_of_expr e)

let store_string_of_return_type rtr =
  match rtr with
  | Dword ->
      int_expr_constr
  | Record s ->
      comment ("record" ^ s)
  | _ ->
      failwith
        ( "RTR "
        ^ string_of_return_type_root rtr
        ^ " not yet supported in store_string_of_expr" )

let store_constr expr =
  match expr with
  | Identifier id ->
      constr_of_coq_type (!typctx id)
  | Integer _ | Add _ | Sub _ ->
      int_expr_constr
  | Gt _ | Lt _ | Eq _ ->
      bool_expr_constr
  | String _ ->
      str_expr_constr
  | ProcCall _ ->
      unit_expr_constr
  | FuncCall (_, rt, _) ->
      store_string_of_return_type rt
  | Subscript (rt, _, _) ->
      store_string_of_return_type (rtr_of_rt rt)
  | Nothing ->
      failwith "Shouldn't be trying to store a Nothing"

let store_string_of_expr e bound_vars =
  parens (string_of_expr e false bound_vars)
(* "("
   ^ econcat " " [store_constr e; "("; string_of_expr e false bound_vars; ")"]
   ^ ")" *)

let rec loop condition body post depth =
  econcat " "
    [ parens
        (econcat " "
           [ "fix"
           ; "loop"
           ; parens (vp_depth ^ " : nat")
           ; parens (broken ^ " : bool")
           ; parens (store_name ^ " : store")
           ; ":="
           ; "\n"
           ; matchwith depth vp_depth
               [ ("O", "None")
               ; ( "S n'"
                 , ifthenelse depth condition
                     (parens ~parens_req_spaces:false
                        (econcat " "
                           [ letin depth store_name
                               (parens ~parens_req_spaces:false
                                  (econcat "\n"
                                     [body; enforce_endswith_store post] ) )
                             (* letin depth store_name
                                    (parens ~parens_req_spaces:false body)
                                ; enforce_endswith_store post *)
                           ; "loop"
                           ; "n'" (* ; parens (id ^ " + 1") *)
                           ; broken
                           ; store_name ] ) )
                     ("Some " ^ store_name) ) ] ] )
    ; "1000%nat"
    ; "false"
    ; store_name ]

and string_of_stmt (extract : bool) ~mid_seq bound_vars depth s =
  (* TODO : For function calls, clear the 'result' variable after using it *)
  let f : stmt -> string = function
    | Nothing ->
        (* comment "nothingn statement" *) ""
    | Break ->
        enforce_endswith_store (letin depth broken "true")
    | Assignment (id, expr) -> (
      match type_of_expr expr with
      | Record ->
          (* Need to find a way to unfold record fields into input variables? Idk *)
          econcat " "
            [ "update_record"
            ; store_name
            ; stringify id
            ; string_of_expr expr false bound_vars ]
      | _ ->
          (* update_typctx id (type_of_expr expr) ; *)
          let s =
            econcat " "
              [ "update"
              ; store_name
              ; stringify id
              ; store_string_of_expr expr bound_vars ]
          in
          if mid_seq then letin depth store_name s else s )
    | Sequence l ->
        econcat "\n"
          ( comment
              ("Block: next " ^ string_of_int (List.length l) ^ " statements")
          :: List.mapi
               (fun i x ->
                 string_of_stmt extract
                   ~mid_seq:(i < List.length l - 1)
                   bound_vars depth x )
               l
             (* @ [store_name] *) )
    | ForLoop (id, el, eh, lb) ->
        (* Check for bound variables *)
        (* Currently, if X is loop iter, lifter will generate (get_int store "VP_X" which is wrong) *)
        (* update_typctx id Z ; *)
        let bound_vars = id :: bound_vars in
        econcat "\n"
          [ (* Whether the loop is iterating upwards or downwards (downto) *)
            letin depth "going_up"
              (string_of_expr (Lt (el, eh)) false bound_vars)
            (* Which function to use to check if the loop bounds have been exceeded *)
          ; letin depth "bounds_op"
              (parens (ifthenelse ~one_line:true depth "going_up" "leb" "geb"))
            (* Which function to use to update the loop counter *)
          ; letin depth "iter_op"
              (parens
                 (ifthenelse ~one_line:true depth "going_up" "add (VInteger 1)"
                    "sub (VInteger 1)" ) )
            (* Set the loop variable to the low bound *)
          ; letin depth store_name
              (econcat " "
                 [ "update"
                 ; store_name
                 ; stringify id
                 ; store_string_of_expr el bound_vars ] )
          ; loop
              (* Condition *)
              (econcat " "
                 [ "bounds_op"
                 ; parens
                     ((* coq_expr_type_getter (Identifier id)
                         ^ " " ^ *)
                      string_of_expr (Identifier id) false
                        bound_vars (* store_name ^ " " ^ stringify id  *) )
                 ; parens (string_of_expr eh false bound_vars) ] )
              ((* Loop body *)
               string_of_stmt extract ~mid_seq:true bound_vars (depth + 1) lb )
              (* Post-loop-body increment/decrement *)
              (letin depth store_name
                 (econcat " "
                    [ "update"
                    ; store_name
                    ; stringify id
                    ; parens
                        (econcat " "
                           [ int_expr_constr
                           ; parens
                               (econcat " "
                                  [ "iter_op"
                                  ; parens
                                      (econcat " "
                                         [ (* coq_expr_type_getter (Integer 0)
                                              ; *)
                                           store_name
                                         ; stringify id ] ) ] ) ] ) ] ) )
              (depth + 1) ]
    | SideEffect e ->
        if e = Nothing then ""
        else
          let content =
            letin depth store_name (string_of_expr e false bound_vars)
          in
          if extract then content else comment content
    | IfThenElse (e, st, sf) ->
        ifthenelse depth
          (string_of_expr e false bound_vars)
          (string_of_stmt extract ~mid_seq bound_vars depth st)
          ( if sf = Nothing then
              if mid_seq then comment "nothing and mid-seq" else store_name
            else string_of_stmt extract ~mid_seq bound_vars depth sf )
  in
  (* comment (string_of_stmt_type s) ^ " " ^  *)
  f s

(*
   Return all identifiers in an expression
*)
and all_ids_in_expr : expr -> string list = function
  | Integer _ | Nothing | String _ ->
      []
  | Identifier id ->
      [id]
  | Add (e1, e2)
  | Sub (e1, e2)
  | Gt (e1, e2)
  | Lt (e1, e2)
  | Eq (e1, e2)
  | Subscript (_, e1, e2) ->
      all_ids_in_expr e1 @ all_ids_in_expr e2
  | ProcCall (_, e) | FuncCall (_, _, e) ->
      List.concat (List.map all_ids_in_expr e)

(*
   Return all identifiers in a statement
*)
and all_ids_in_stmt : stmt -> string list = function
  | Nothing | Break ->
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

and runtime_check = function ForLoop _ -> true | _ -> false

(*
   Wrapper for string_of_stmt that adds a "poison check," essentially capturing
   runtime errors, including:

   - Undefined variable (not a runtime error, added for practice)
*)
and poison_check extract bound_vars depth (stmt : stmt) =
  (* TODO : For all stores in a statement, ensure that
     if the ident already exists, the type of its new value
     matches the type of its old value. If not, poisoned.
  *)
  if stmt = Nothing then ""
  else
    letins depth [store_name; poison]
      [ ifthenelse ~noindent_first:true (depth + 1)
          (* Add this in when more runtime checks needed *)
          (* (econcat " "
             ["multi_ands"; square_braces (econcat " " ["negb"; poison])] ) *)
          (econcat " " ["negb"; poison])
          ( if runtime_check stmt then
              econcat " "
                [ matchwith ~noindent_first:true depth
                    (enforce_endswith_store
                       (string_of_stmt extract ~mid_seq:false bound_vars
                          (depth + 1) stmt ) )
                    [ ("None", pair store_name "true")
                    ; ( "Some " ^ store_name ^ "'"
                      , pair (store_name ^ "'") poison ) ] ]
            else
              pair
                ( if stmt = Nothing then store_name
                  else
                    enforce_endswith_store
                      (string_of_stmt extract ~mid_seq:false bound_vars depth
                         stmt ) )
                poison )
          (pair store_name "true") ]

(* Generate function/procedure definitions *)
let rec _str_of_gal_aux ?(depth = 1) (extract : bool) bound_vars = function
  (* TODO : For functions, return should be original passed-in store with result var set,
     should naturally handle function scopes *)
  | Root (pt, gal) ->
      ( false
      , ( match pt.func_type with
        | Procedure (id, rtl) ->
            econcat " "
              ( [definition_str; sanitize_id id; "(" ^ store_name ^ ": store)"]
              @ List.mapi
                  (fun i rt ->
                    let t = match rt with RT n | Const n -> n | Var n -> n in
                    econcat " "
                      [ "("
                      ; "arg" ^ string_of_int i
                      ; ":"
                      ; string_of_coq_type (coq_type_of_return_type_root t)
                      ; ")" ] )
                  rtl
              @ [":="; "\n"] )
        | Function (id, rtl, rt) ->
            econcat " "
              ( [definition_str; sanitize_id id; "(" ^ store_name ^ ": store)"]
              (* Not sure how I'll handle func args yet *)
              (* @ List.mapi
                  (fun i rt ->
                    let t = match rt with RT n | Const n -> n | Var n -> n in
                    econcat " "
                      [ "("
                      ; "arg" ^ string_of_int i
                      ; ":"
                      ; string_of_coq_type (coq_type_of_return_type_root t)
                      ; ")" ] )
                  rtl *)
              @ [":="; "\n"] )
        | _ ->
            failwith "Expected procedure or function as root node" )
        ^ snd (_str_of_gal_aux extract bound_vars gal) )
  | Sequence gl ->
      ( false
      , econcat "\n"
          ( [letin depth poison "false"]
          @ List.map (fun g -> snd (_str_of_gal_aux extract bound_vars g)) gl
          @ [store_name] ) )
  | Statement s ->
      (false, poison_check extract bound_vars depth s)
  | Comment s ->
      (true, comment s)

(* Entry function *)
let string_of_gallina do_preamble fn extract extract_lang extract_path func_name
    g gamma =
  typctx := gamma ;
  let is_comment, body = _str_of_gal_aux extract [] g in
  econcat "\n"
    [ (if do_preamble then preamble extract extract_lang else "")
    ; (body ^ if not is_comment then "." else "")
    ; ( if extract && not is_comment then
          extraction fn func_name extract_lang extract_path
        else "" ) ]
  ^ "\n"
