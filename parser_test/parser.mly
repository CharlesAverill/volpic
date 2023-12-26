%{
    open Tree
%}

%token <int>    NUMBER
%token <string> IDENTIFIER

%token LEFT_PARENTHESIS RIGHT_PARENTHESIS
%token COMMA
%token EOF

%start main
%type <Tree.tree list> main nodes
%type <Tree.tree> node

%%

main :
      EOF  { [] }
    | nodes { $1 }

nodes : { [] }
    | node        { [$1] }
    | node nodes  { $1 :: $2 }

node :
      LEFT_PARENTHESIS NUMBER RIGHT_PARENTHESIS               { Leaf $2 }
    | LEFT_PARENTHESIS NUMBER COMMA nodes idents RIGHT_PARENTHESIS   { Node ($2, $4, $5) }

idents :
      { [] }
    | IDENTIFIER idents { [$1] @ $2 }
