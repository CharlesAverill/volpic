(*Preamble*)
Require Import Volpic_preamble.
Require Import String.
Require Import ZArith.
Require Import List.
Require Import Bool.
Open Scope string_scope.
Open Scope Z_scope.
Import ListNotations.


Definition test (VP_store: store) ( arg0 : Z ) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_X" (Integer ( 99 )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [ "VP_X" ] ) ) then (update VP_store "VP_result" (Integer ( get_int VP_store "VP_X" - 9 )),VP_poison) else (VP_store,true)) in
	VP_store.

Definition main (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_Y" (Integer ( 6 )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [ "VP_Y" ] ) ) then (update VP_store "VP_X" (Integer ( 5 + get_int VP_store "VP_Y" )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [ "VP_Y" ] ) ) then (update VP_store "VP_X" (Integer ( get_int (test VP_store (get_int VP_store "VP_Y")) "VP_result" )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [ "VP_X" ] ) ) then ((*Block: next 6 statements*)
	(*nothingn statement*)
	(*nothingn statement*)
	(*nothingn statement*)
	(*let VP_store := fpc_write_text_uint VP_store (get_int VP_store "VP_X") 0 in*)
	(*let VP_store := fpc_writeln_end VP_store in*)
	(*nothingn statement*)
	VP_store,VP_poison) else (VP_store,true)) in
	VP_store.

Compute get_int (main fresh_store) "VP_X".
