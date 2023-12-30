(*Preamble*)
Require Import Volpic_preamble.
Require Import String.
Require Import ZArith.
Require Import List.
Require Import Bool.
Require Import ExtrOcamlBasic.
Require Import ExtrOcamlString.
Extraction Language OCaml.
Open Scope string_scope.
Open Scope Z_scope.
Import ListNotations.


Definition main (VP_store : store) :=
	let VP_poison := false in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [  ] ) ) then (update VP_store "VP_Y" (Integer ( 6 )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [ "VP_Y" ] ) ) then (update VP_store "VP_X" (Integer ( 5 + get_int VP_store "VP_Y" )),VP_poison) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if ( andb ( negb VP_poison ) ( all_in_ids VP_store [ "VP_X" ] ) ) then ((*Block: next 6 statements*)
	(*nothingn statement*)
	(*nothingn statement*)
	(*nothingn statement*)
	let VP_store := fpc_write_text_uint VP_store (get_int VP_store "VP_X") 0 in
	let VP_store := fpc_writeln_end VP_store in
	(*nothingn statement*)
	VP_store,VP_poison) else (VP_store,true)) in
	VP_store.
Extraction "print5.ml" main.