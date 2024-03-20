Require Import Volpic_preamble.

Declare Scope volpic_notation.
Open Scope volpic_notation.

Notation "'_' '!->' v" := (fresh_store v)
    (at level 100, right associativity) : volpic_notation.
Notation "x '!->' y ';' f" := (update f x y)
    (at level 100, y at next level, right associativity) : volpic_notation.

Notation "'while' '(' condition ')' 'with' store_name 'upto' loop_limit 'begin' loop_body 'end'" :=
    ((fix loop (depth : nat) (broken : bool) (VP_store : store) :=
        match depth with 
        | O => None
        | S n' => 
            if condition VP_store then 
                loop n' broken (loop_body VP_store)
            else 
                (Some VP_store)
        end) loop_limit false store_name
    ) : volpic_notation.
    
Close Scope volpic_notation.
