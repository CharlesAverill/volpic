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

Definition main (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := (if (multi_ands [negb VP_poison]) then 
		(match (let bounds_op := Z.leb in let VP_store := update VP_store "VP_X" (VInteger ( 0 )) in 
		(fix loop (VP_depth : nat) (VP_store : store) := 
		match (VP_depth) with 
		| O => None 
		| S n' => if (bounds_op (get_int VP_store "VP_X") 5) then 
			(let VP_store := update VP_store "VP_Y" (VInteger ( get_int VP_store "VP_X" + get_int VP_store "VP_Y" )) 
				in let VP_store := update VP_store "VP_X" (VInteger ( get_int VP_store "VP_X" + 1 )) 
				in loop n' VP_store) 
		else (Some VP_store) end) 1000%nat VP_store) with | None => (VP_store,true) | Some VP_store' => (VP_store',VP_poison) end) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if (multi_ands [negb VP_poison]) then (match (let bounds_op := Z.geb in let VP_store := update VP_store "VP_X" (VInteger ( 5 )) in (fix loop (VP_depth : nat) (VP_store : store) := match (VP_depth) with | O => None | S n' => if (bounds_op (get_int VP_store "VP_X") 0) then (let VP_store := update VP_store "VP_Y" (VInteger ( get_int VP_store "VP_X" + get_int VP_store "VP_Y" )) in let VP_store := update VP_store "VP_X" (VInteger ( get_int VP_store "VP_X" - 1 )) in loop n' VP_store) else (Some VP_store) end) 1000%nat VP_store) with | None => (VP_store,true) | Some VP_store' => (VP_store',VP_poison) end) else (VP_store,true)) in
	let (VP_store,VP_poison) := (if (multi_ands [negb VP_poison]) then ((*Block: next 6 statements*)
	let VP_store := fpc_write_text_uint VP_store (get_int VP_store "VP_Y") 0 in
	let VP_store := fpc_writeln_end VP_store in
	VP_store,VP_poison) else (VP_store,true)) in
	VP_store.
Extraction "print5.ml" main.

Compute get_int (main fresh_store) "VP_Y".
