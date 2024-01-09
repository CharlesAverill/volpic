(*Preamble*)
Require Import Volpic_preamble.
Require Import String.
Require Import ZArith.
Require Import List.
Require Import Bool.
Open Scope string_scope.
Open Scope Z_scope.
Import ListNotations.


Definition test (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_RESULT_B0" (VInteger ( 99 )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_result_B0" (VInteger ( 9 )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_result_B1" (VInteger ( 10 )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_result_B2" (VString ( "bye" )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_result_B3" (VString ( "world" )),VP_poison) else (VP_store,true)) in
	VP_store.

Definition initialize (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then ((*Block: next 6 statements*)
	(*nothingn statement*)
	(*nothingn statement*)
	(*nothingn statement*)
	(*let VP_store := fpc_write_text_shortstr VP_store ("hello world") 0 in*)
	(*let VP_store := fpc_writeln_end VP_store in*)
	(*nothingn statement*)
	VP_store,VP_poison) else (VP_store,true)) in
	VP_store.

Definition main (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update_record VP_store "VP_X" ((test VP_store)) "VP_result",VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then ((*let VP_store := initialize VP_store in*),VP_poison) else (VP_store,true)) in
	VP_store.

Compute (main fresh_store).