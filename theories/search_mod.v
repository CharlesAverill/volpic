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

(* Theorem test : forall x y, (x <? y)%nat = true -> vector Z (x + (y - x))%nat -> vector Z y.
intros. rewrite Arith_prebase.le_plus_minus_r_stt in X. exact X. 
apply Nat.ltb_lt in H. now apply Nat.lt_le_incl in H. Defined.

Definition setlength (s : store) (id : string) (new_len : nat) 
	{old_len : nat} (old_vec : vector Z old_len) : store.
	destruct (old_len <? new_len)%nat eqn:E.
	- remember (Vector.append old_vec (pad_vec (new_len - old_len) 0)) as new_vec.
	  assert (vector Z new_len). {
	 	exact (test old_len new_len E new_vec). 
	  } exact (update s id (VArray Z new_len X)).
	- remember (int_array_take new_len old_vec) as new_vec. 
	  exact (update s id (VArray Z new_len new_vec)).
Defined. *)


Definition main (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_EL" (VInteger ( 99 )),VP_poison) 
		else
 			(VP_store,true)) in
	(* let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := get_array (setlength VP_store 10 (get_array VP_store "VP_ARR")) "VP_result" in VP_store,VP_poison) 
		else
 			(VP_store,true)) in *)
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? 10 in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_IDX" (VInteger ( 0 )) in
(fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_IDX") 10) then
 				 (let VP_store := (let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)ARR" (VInteger ( get_int VP_store "VP_IDX" )) in
		let VP_store := update VP_store "VP_IDX" (VInteger (iter_op (get_int VP_store "VP_IDX"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)ARR" (VInteger ( get_int VP_store "VP_EL" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result" in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_IDX" (VInteger ( 0 )) in
(fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_IDX") (get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result")) then
 				 (let VP_store := (let VP_store := if (subscript (get_array VP_store "VP_ARR") (Z.to_nat (get_int VP_store "VP_IDX")) 0 =? get_int VP_store "VP_EL") then
 	 (let VP_broken := true in VP_store) 
else
 	((*nothing and mid-seq*) VP_store) in
		let VP_store := update VP_store "VP_IDX" (VInteger (iter_op (get_int VP_store "VP_IDX"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store (string_of_char_list ("Element: ")) in
	let VP_store := fpc_write_text_sint VP_store (get_int VP_store "VP_EL") 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store (string_of_char_list ("Index: ")) in
	let VP_store := fpc_write_text_sint VP_store (get_int VP_store "VP_IDX") 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store (string_of_char_list "arr[idx]: ") in
	let VP_store := fpc_write_text_sint VP_store (subscript (get_array VP_store "VP_ARR") (Z.to_nat (get_int VP_store "VP_IDX")) 0) 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "search.ml" main.

Compute get_int (main fresh_store) "VP_IDX".
