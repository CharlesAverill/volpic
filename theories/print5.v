From Volpic Require Import Volpic_preamble.
Require Import String.
Open Scope string_scope.
Definition main (VOLPIC_store : store) := 
        let VOLPIC_store := update VOLPIC_store "X" (Integer 5) in
        VOLPIC_store.
