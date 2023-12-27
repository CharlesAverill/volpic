Require Import String.

Definition id_type := string.

Inductive value : Type :=
| Integer   (n : nat)
| String    (s : string).

Definition store := id_type -> option value.

Definition fresh_store : store := fun _ => None.

Definition update (VOLPIC_store : store) (s : id_type) (v : value) :=
    fun x => if string_dec x s then Some v else VOLPIC_store s.
