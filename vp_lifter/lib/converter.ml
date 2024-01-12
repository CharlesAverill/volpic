open Parse_tree

type id_type = string

type expr =
  | Nothing
  | Identifier of id_type
  | Integer of int
  | String of string
  | Add of expr * expr
  | Sub of expr * expr
  | Gt of expr * expr
  | Lt of expr * expr
  | ProcCall of (id_type * expr list)
  (* identifier, return type, args *)
  | FuncCall of (id_type * return_type_root * expr list)

type stmt =
  | Nothing
  | Assignment of (id_type * expr)
  | Sequence of stmt list
  | SideEffect of expr
  | IfThenElse of (expr * stmt * stmt)
  (* Iterator, min, max, body *)
  | ForLoop of (id_type * expr * expr * stmt)

type gallina =
  | Root of parse_tree_node * gallina
  | Sequence of gallina list
  | Statement of stmt
  | Comment of string

let rec id_of_parse_tree parse_tree =
  match parse_tree.pt_type with
  | Load ->
      string_of_vtype (find_data parse_tree.data "symbol")
  | Typeconv ->
      id_of_parse_tree (List.hd parse_tree.children)
  | Subscript ->
      String.concat ""
        [ id_of_parse_tree (List.hd parse_tree.children)
        ; "_"
        ; string_of_vtype (find_data parse_tree.data "field") ]
  | _ ->
      failwith
        ( "Unexpected node type "
        ^ string_of_parse_tree_type parse_tree.pt_type
        ^ ", expected identifier node" )

let rec expr_of_parse_tree parse_tree =
  match parse_tree.pt_type with
  | Ordconst ->
      Integer
        (int_of_string (string_of_vtype (find_data parse_tree.data "value")))
  | Load ->
      Identifier (string_of_vtype (find_data parse_tree.data "symbol"))
  | Add ->
      Add
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Sub ->
      Sub
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
  | Typeconv ->
      expr_of_parse_tree (List.hd parse_tree.children)
  | Call -> (
      let procdata = find_data parse_tree.data "proc" in
      let proc = string_of_vtype procdata in
      match procdata with
      | ProcFunc (id, _, rt) ->
          if rt = "" then ProcCall (proc, find_parans parse_tree.children)
          else
            FuncCall
              ( id
              , return_type_root_of_string rt
              , find_parans parse_tree.children )
      | _ ->
          failwith ("Expected procedure or Function call, but got " ^ proc) )
  | Callpara ->
      List.hd (find_parans [parse_tree])
  | Deref ->
      Nothing
  | Stringconst ->
      String (string_of_vtype (find_data parse_tree.data "value"))
  | Nothing ->
      Nothing
  | _ ->
      failwith
        ( string_of_parse_tree_type parse_tree.pt_type
        ^ " not yet supported for expression parsing" )

and find_parans l =
  List.map
    (fun x ->
      match x.pt_type with
      | Callpara ->
          expr_of_parse_tree (List.hd x.children)
      | _ ->
          failwith
            ( string_of_parse_tree_type x.pt_type
            ^ " not yet supported for function argument parsing" ) )
    l

let rec stmt_of_parse_tree parse_tree =
  match parse_tree.pt_type with
  | Assign ->
      if (List.hd parse_tree.children).pt_type = Tempref then Nothing
      else
        Assignment
          ( id_of_parse_tree (List.hd parse_tree.children)
          , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | Block ->
      Sequence (List.map stmt_of_parse_tree parse_tree.children)
  | Statement ->
      stmt_of_parse_tree (List.hd parse_tree.children)
  | Nothing | Tempcreate | Tempdelete ->
      Nothing
  | If ->
      (*
        First child - Condition
        Second child - Positive Case
        Third child - Negative Case
      *)
      IfThenElse
        ( expr_of_parse_tree (List.hd parse_tree.children)
        , stmt_of_parse_tree (List.nth parse_tree.children 1)
        , if List.length parse_tree.children > 2 then
            stmt_of_parse_tree (List.nth parse_tree.children 2)
          else Nothing )
  | For ->
      ForLoop
        ( ( match find_data (List.hd parse_tree.children).data "symbol" with
          | Str s ->
              s
          | _ ->
              failwith "Failed to find iterator symbol for loop" )
        , expr_of_parse_tree (List.nth parse_tree.children 1)
        , expr_of_parse_tree (List.nth parse_tree.children 2)
        , stmt_of_parse_tree (List.nth parse_tree.children 3) )
  | Call ->
      SideEffect
        (let proc = find_data parse_tree.data "proc" in
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
             failwith ("Expected ProcFunc, got " ^ string_of_vtype proc) )
      (* (ProcCall
         ( string_of_vtype (find_data parse_tree.data "proc")
         , List.map expr_of_parse_tree parse_tree.children ) ) *)
  | _ ->
      failwith
        ( string_of_parse_tree_type parse_tree.pt_type
        ^ " not yet supported for statement parsing" )

let rec gallina_of_parse_tree depth parse_tree =
  if depth = 0 then
    Root (parse_tree, gallina_of_parse_tree (depth + 1) parse_tree)
  else
    match parse_tree.pt_type with
    | Block ->
        Sequence
          (List.map (gallina_of_parse_tree (depth + 1)) parse_tree.children)
    | Statement ->
        Statement (stmt_of_parse_tree (List.hd parse_tree.children))
    | _ ->
        failwith
          ( string_of_parse_tree_type parse_tree.pt_type
          ^ " not yet supported for block parsing" )
