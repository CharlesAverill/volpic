(*Preamble*)
Require Import Volpic_preamble.
Require Import String.
Require Import ZArith.
Require Import List.
Require Import Bool.
Open Scope string_scope.
Open Scope Z_scope.
Import ListNotations.


Definition main (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_X" (VInteger ( 6 )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [ "VP_X";"VP_X" ] ) ) then (if get_int VP_store "VP_X" <? 5 then update VP_store "VP_X" (VInteger ( 1 )) else if get_int VP_store "VP_X" >? 5 then update VP_store "VP_X" (VInteger ( 2 )) else update VP_store "VP_X" (VInteger ( 3 )),VP_poison) else (VP_store,true)) in
	VP_store.

	Compute get_int (main fresh_store) "VP_X".
