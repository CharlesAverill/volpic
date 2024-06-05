Require Import Volpic_preamble.

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
