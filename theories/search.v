(*Preamble*)
Require Import Volpic_preamble.
Require Import String.
Require Import ZArith.
Require Import List.
Require Import Bool.
Require Import ExtrOcamlBasic.
Require Import ExtrOcamlString.
Require Import Vector.
Extraction Language OCaml.
Open Scope string_scope.
Open Scope Z_scope.
Import VectorNotations.


Definition main (VP_store: store) := 
	let VP_store := update VP_store "VP_EL" (VInteger 99) in 
	let VP_store := update VP_store "VP_ARR" (VArray Z 10%nat [1;2;3;4;5;6;99;8;9;10]) in
	let VP_poison := false in
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
 				 (let VP_store := (let VP_store := if (subscript (get_array VP_store "VP_ARR") (Z.to_nat (get_int VP_store "VP_IDX")) 0 =? 99) then
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
	let VP_store := fpc_write_text_shortstr VP_store (string_of_char_list "Element: ") in
	let VP_store := fpc_write_text_sint VP_store 99 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store (string_of_char_list "Index: ") in
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

Compute (main fresh_store).
