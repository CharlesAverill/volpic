(*Preamble*)
Require Import Volpic_preamble.
Require Import String.
Require Import ZArith.
Require Import List.
Require Import Bool.
Open Scope string_scope.
Open Scope Z_scope.
Import ListNotations.

Definition main (VP_store : store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_Y" (Integer ( 6 )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [ "VP_Y" ] ) ) then (update VP_store "VP_X" (Integer ( 5 + get_int VP_store "VP_Y" )),VP_poison) else (VP_store,true)) in
	(VP_store, VP_poison).

Compute Volpic_preamble.get (fst (main fresh_store)) "VP_X".
