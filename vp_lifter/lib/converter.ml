open Parse_tree
open Logging

type id_type = string

type expr =
  | Nothing
  | Identifier of id_type
  | Integer of int
  | String of string
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Gt of expr * expr
  | Lt of expr * expr
  | Geq of expr * expr
  | Leq of expr * expr
  | Eq of expr * expr
  | Uneq of expr * expr
  | ProcCall of (id_type * expr list)
  (* identifier, return type, args *)
  | FuncCall of (id_type * return_type_root * expr list)
  | Subscript of return_type * expr * expr

type stmt =
  | Nothing
  | Assignment of (id_type * expr)
  | Sequence of stmt list
  | SideEffect of expr
  | IfThenElse of (expr * stmt * stmt)
  (* Iterator, min, max, body *)
  | ForLoop of (id_type * expr * expr * stmt)
  (* Condition, body *)
  | WhileLoop of (expr * stmt)
  | Break

let string_of_stmt_type = function
  | Nothing ->
      "Nothing"
  | Assignment _ ->
      "Assignment"
  | Sequence _ ->
      ";"
  | SideEffect _ ->
      "Side Effect"
  | IfThenElse _ ->
      "If"
  | ForLoop _ ->
      "For"
  | WhileLoop _ ->
      "While"
  | Break ->
      "Break"

type gallina =
  | Root of parse_tree_node * gallina
  | Sequence of gallina list
  | Statement of stmt
  | Comment of string

type coq_type = Error | Z | String | Unit | Record | Bool | Vector of coq_type

let rec string_of_coq_type = function
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
  | Vector s ->
      "vector" ^ " " ^ string_of_coq_type s
  | Error ->
      failwith (* fatal rc_CoqError *) "Tried to get string of error coq type"

let rec coq_type_of_return_type_root r =
  match r with
  | Dword
  | LongWord
  | StrNumber
  | Int64
  | SmallInt
  | LongInt
  | Word
  | Byte
  | Char
  | ShortInt ->
      Z
  | ShortString ->
      String
  | Record _ ->
      Record
  | Array (_, _, r) ->
      Vector (coq_type_of_return_type_root r)
  | _ ->
      failwith (* fatal rc_CoqError *)
        ("Haven't set coq type for RTR " ^ string_of_return_type_root r)

type typ_ctx = id_type -> coq_type

let fresh_gamma s : coq_type =
  failwith
    (* fatal rc_CoqError *) ("Trying to check type of undeclared var " ^ s)

let gamma = ref fresh_gamma

let ids = ref []

let update_typctx id value =
  ids := if List.exists (fun i -> i = id) !ids then !ids else id :: !ids ;
  let old = !gamma in
  gamma := fun x -> if x = id then value else old x

let rec id_of_parse_tree parse_tree =
  match parse_tree.pt_type with
  | Load ->
      string_of_vtype (find_data parse_tree.data "symbol")
  | Typeconv ->
      id_of_parse_tree (List.hd parse_tree.children)
  | Vec ->
      "(* This is a vecn id_of_parse_tree, something's gonna go wrong *)"
      ^ id_of_parse_tree (List.hd parse_tree.children)
  | Subscript ->
      String.concat ""
        [ id_of_parse_tree (List.hd parse_tree.children)
        ; "_"
        ; string_of_vtype (find_data parse_tree.data "field") ]
  | _ ->
      failwith (* fatal rc_ConversionError *)
        ( "Unexpected node type "
        ^ string_of_parse_tree_type parse_tree.pt_type
        ^ ", expected identifier node" )

let proc_of_inline i =
  match i with
  | "in_setlength_x" ->
      ProcFunc
        ( "vp_setlength"
        , "Int64"
        , (* "{dynamic} array of nil" *)
          (* not sure why I had this for a while?*)
          "" )
  | "in_length_x" ->
      ProcFunc
        ( "vp_length"
        , (* "Int64", "{dynamic} array of nil" *)
          (* Same here?*)
          "array of int"
        , "Int64" )
  | _ ->
      failwith ("Inline function " ^ i ^ " not yet supported")

let rec expr_of_parse_tree parse_tree =
  match parse_tree.pt_type with
  | Ordconst ->
      Integer
        (int_of_string (string_of_vtype (find_data parse_tree.data "value")))
  | Load ->
      update_typctx
        (string_of_vtype (find_data parse_tree.data "symbol"))
        (coq_type_of_return_type_root (rtr_of_rt parse_tree.resultdef)) ;
      Identifier (string_of_vtype (find_data parse_tree.data "symbol"))
  | Add ->
      Add
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Sub ->
      Sub
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Mul ->
      Mul
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Div ->
      Div
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Gt ->
      Gt
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Lt ->
      Lt
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Lte ->
      Leq
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Gte ->
      Geq
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Equal ->
      Eq
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Unequal ->
      Uneq
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Typeconv ->
      expr_of_parse_tree (List.hd parse_tree.children)
  | Vec ->
      let children = List.map expr_of_parse_tree parse_tree.children in
      if List.length children = 2 then
        Subscript
          (parse_tree.resultdef, List.nth children 0, List.nth children 1)
        (* match (List.nth children 0, List.nth children 1) with
           | Identifier arr_name, Identifier idx ->
               Subscript (parse_tree.resultdef, Identifier arr_name, Identifier idx)
           | Identifier arr_name, Integer idx ->
               Subscript (parse_tree.resultdef, Identifier arr_name, Integer idx)
           | _ ->
               failwith (* fatal rc_ConversionError *) "Unrecognized vecn form" *)
      else failwith (* fatal rc_ConversionError *) "Unrecognized vecn form"
  | Call -> (
      let procdata = find_data parse_tree.data "proc" in
      let proc = string_of_vtype procdata in
      (* get_procfunc parse_tree procdata *)
      match procdata with
      | ProcFunc (id, _, rt) ->
          if rt = "" then ProcCall (proc, find_parans parse_tree.children)
          else
            FuncCall
              ( id
              , return_type_root_of_string rt
              , find_parans parse_tree.children )
      | _ ->
          exc Log_Error ("Expected procedure or Function call, but got " ^ proc)
      )
  | Inline ->
      let proc =
        proc_of_inline
          (string_of_optional (find_data parse_tree.optionals "inlinenumber"))
      in
      get_procfunc parse_tree proc
      (* match proc with
         | ProcFunc (id, _, rt) ->
             if rt = "" then ProcCall (id, find_parans parse_tree.children)
             else
               FuncCall
                 ( id
                 , return_type_root_of_string rt
                 , find_parans parse_tree.children )
         | _ ->
             exc Log_Error
               ( "Expected procedure or Function call, but got "
               ^ string_of_vtype proc ) *)
  | Callpara ->
      List.hd (find_parans [parse_tree])
  | Deref ->
      Nothing
  | Stringconst ->
      String (string_of_vtype (find_data parse_tree.data "value"))
  | Nothing | Emptynode ->
      Nothing
  | _ ->
      exc Log_Error
        ( string_of_parse_tree_type parse_tree.pt_type
        ^ " not yet supported for expression parsing" )

and find_parans l =
  List.map
    (fun x ->
      match x.pt_type with
      | Callpara ->
          expr_of_parse_tree (List.hd x.children)
      | Load ->
          expr_of_parse_tree (List.hd x.children)
      | _ ->
          exc Log_Error
            ( string_of_parse_tree_type x.pt_type
            ^ " not yet supported for function argument parsing" ) )
    l

and get_procfunc (parse_tree : parse_tree_node) proc =
  match proc with
  | ProcFunc (id, args, rt) ->
      if rt = "" then
        ProcCall (id, List.map expr_of_parse_tree parse_tree.children)
      else
        FuncCall
          ( id
          , return_type_root_of_string rt
          , List.map expr_of_parse_tree parse_tree.children )
  | _ ->
      failwith (* fatal rc_ConversionError *)
        ("Expected ProcFunc, got " ^ string_of_vtype proc)

let rec stmt_of_parse_tree parse_tree =
  match parse_tree.pt_type with
  | Assign ->
      if (List.hd parse_tree.children).pt_type = Tempref then Nothing
      else
        Assignment
          ( id_of_parse_tree (List.hd parse_tree.children)
          , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Block ->
      if List.length parse_tree.children = 1 then
        stmt_of_parse_tree (List.hd parse_tree.children)
      else Sequence (List.map stmt_of_parse_tree parse_tree.children)
  | Statement ->
      stmt_of_parse_tree (List.hd parse_tree.children)
  | Nothing | Tempcreate | Tempdelete | Emptynode ->
      Nothing
  | If ->
      (*
        First child - Condition
        Second child - Positive Case
        Third child - Negative Case
      *)
      if List.length parse_tree.children < 3 then
        failwith "If statement with fewer than 3 children"
      else
        IfThenElse
          ( expr_of_parse_tree (List.hd parse_tree.children)
          , stmt_of_parse_tree (List.nth parse_tree.children 1)
          , if List.length parse_tree.children > 2 then
              stmt_of_parse_tree (List.nth parse_tree.children 2)
            else Nothing )
  | For ->
      if List.length parse_tree.children < 4 then
        failwith "For loop has fewer than 4 children"
      else
        ForLoop
          ( ( match find_data (List.hd parse_tree.children).data "symbol" with
            | Str s ->
                s
            | _ ->
                failwith
                  (* fatal rc_ConversionError *)
                  "Failed to find iterator symbol for loop" )
          , expr_of_parse_tree (List.nth parse_tree.children 1)
          , expr_of_parse_tree (List.nth parse_tree.children 2)
          , stmt_of_parse_tree (List.nth parse_tree.children 3) )
  | Whilerepeat ->
      WhileLoop
        ( expr_of_parse_tree (List.nth parse_tree.children 0)
        , stmt_of_parse_tree (List.nth parse_tree.children 1) )
  | Break ->
      Break
  | Call ->
      SideEffect
        (let proc = find_data parse_tree.data "proc" in
         get_procfunc parse_tree proc )
      (* (ProcCall
         ( string_of_vtype (find_data parse_tree.data "proc")
         , List.map expr_of_parse_tree parse_tree.children ) ) *)
  | Inline ->
      SideEffect
        (let proc =
           proc_of_inline
             (string_of_optional
                (find_data parse_tree.optionals "inlinenumber") )
         in
         get_procfunc parse_tree proc )
  | _ ->
      exc Log_Error
        ( string_of_parse_tree_type parse_tree.pt_type
        ^ " not yet supported for statement parsing" )

let rec _gallina_of_parse_tree depth parse_tree =
  if depth = 0 then
    Root (parse_tree, _gallina_of_parse_tree (depth + 1) parse_tree)
  else
    match parse_tree.pt_type with
    | Block ->
        Sequence
          (List.map (_gallina_of_parse_tree (depth + 1)) parse_tree.children)
    | Statement ->
        Statement (stmt_of_parse_tree (List.hd parse_tree.children))
    | _ ->
        exc Log_Error
          ( string_of_parse_tree_type parse_tree.pt_type
          ^ " not yet supported for block parsing" )

let gallina_of_parse_tree parse_tree =
  gamma := fresh_gamma ;
  ids := [] ;
  (* Compute this before putting in tuple to ensure !gamma and !ids eval properly *)
  let g = _gallina_of_parse_tree 0 parse_tree in
  _log Log_Debug
    (String.concat ", "
       (List.map (fun id -> id ^ ": " ^ string_of_coq_type (!gamma id)) !ids) ) ;
  (g, !gamma, !ids)
