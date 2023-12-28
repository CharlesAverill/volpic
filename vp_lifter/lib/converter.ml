open Parse_tree

type id_type = string

type expr = Identifier of id_type | Integer of int | Add of expr * expr

type stmt = Assignment of (id_type * expr)

type gallina = Sequence of gallina list | Statement of stmt

let id_of_parse_tree parse_tree =
  match parse_tree.pt_type with
  | Load ->
      string_of_vtype (find_data parse_tree.data "symbol")
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
  | _ ->
      failwith
        ( string_of_parse_tree_type parse_tree.pt_type
        ^ " not yet supported for expression parsing" )

let stmt_of_parse_tree parse_tree =
  match parse_tree.pt_type with
  | Assignment ->
      Assignment
        ( id_of_parse_tree (List.hd parse_tree.children)
        , expr_of_parse_tree (List.hd (List.tl parse_tree.children)) )
  | _ ->
      failwith
        ( string_of_parse_tree_type parse_tree.pt_type
        ^ " not yet supported for statement parsing" )

let rec gallina_of_parse_tree parse_tree =
  match parse_tree.pt_type with
  | Block ->
      Sequence (List.map gallina_of_parse_tree parse_tree.children)
  | Statement ->
      Statement (stmt_of_parse_tree (List.hd parse_tree.children))
  | _ ->
      failwith
        ( string_of_parse_tree_type parse_tree.pt_type
        ^ " not yet supported for block parsing" )
