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


Definition print_arr (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 6 statements*)
	let VP_store := fpc_write_text_char VP_store 91 0 in
	let VP_store := fpc_write_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result" in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 0 )) in
			let loop := (fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") (get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result")) then
 				 (let VP_store := ((*Block: next 2 statements*)
(*Block: next 6 statements*)
			let VP_store := fpc_write_text_ansistr VP_store ((IntToStr VP_store (subscript (get_array VP_store "VP_ARR") (get_int VP_store "VP_I") 0)) "VP_result") 0 in
			let VP_store := fpc_write_end VP_store in
			let VP_store := if (get_int VP_store "VP_I" !=? get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result") then
 	 ((*Block: next 6 statements*)
			let VP_store := fpc_write_text_shortstr VP_store (", ") 0 in
			let VP_store := fpc_write_end VP_store in VP_store) 
else
 	VP_store in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) in loop 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 6 statements*)
	let VP_store := fpc_write_text_char VP_store 93 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" print_arr.

Definition bubble_sort (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := get_array (setlength VP_store (get_array (length VP_store) "VP_result") (get_array VP_store "VP_result")) "VP_result" in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result" in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 0 )) in
			let loop := (fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") (get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result")) then
 				 (let VP_store := (let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)result" (VInteger ( subscript (get_array VP_store "VP_ARR") (get_int VP_store "VP_I") 0 )) in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) in loop 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_result")) "VP_result" - 1 <? 0 in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_result")) "VP_result" - 1 )) in
			let loop := (fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") 0) then
 				 (let VP_store := (let going_up := 0 <? get_int VP_store "VP_I" in
			let bounds_op := (if going_up then Z.leb else Z.geb) in
			let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
			let VP_store := update VP_store "VP_J" (VInteger ( 0 )) in
				let loop := (fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 				 match VP_depth with 
 					 | O => None
					 | S n' => if (bounds_op (get_int VP_store "VP_J") (get_int VP_store "VP_I")) then
 					 (let VP_store := (let VP_store := if (subscript (get_array VP_store "VP_result") (get_int VP_store "VP_J") 0 >? subscript (get_array VP_store "VP_result") (get_int VP_store "VP_J" + 1) 0) then
 	 (*Block: next 3 statements*)
				let VP_store := update VP_store "VP_TEMP" (VInteger ( subscript (get_array VP_store "VP_result") (get_int VP_store "VP_J") 0 )) in
				let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)result" (VInteger ( subscript (get_array VP_store "VP_result") (get_int VP_store "VP_J" + 1) 0 )) in
update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)result" (VInteger ( get_int VP_store "VP_TEMP" )) 
else
 	((*nothing and mid-seq*) VP_store) in
			let VP_store := update VP_store "VP_J" (VInteger (iter_op (get_int VP_store "VP_J"))) in VP_store) in loop n' VP_broken VP_store) 
				else
 					(Some VP_store)
					 				 end) in loop 1000%nat false VP_store
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) in loop 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (constr_varray ( get_array VP_store "VP_result" )),VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" bubble_sort.

Definition simple_loop (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? 10 in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 0 )) in
			let loop := (fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") 10) then
 				 (let VP_store := ((*Block: next 6 statements*)
			let VP_store := fpc_write_text_uint VP_store (get_int VP_store "VP_I") 0 in
			let VP_store := fpc_writeln_end VP_store in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) in loop 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" simple_loop.

Definition linear_search (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (VInteger ( -1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result" in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 0 )) in
			let loop := (fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") (get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result")) then
 				 (let VP_store := (let VP_store := if (subscript (get_array VP_store "VP_ARR") (get_int VP_store "VP_I") 0 =? get_int VP_store "VP_KEY") then
 	 ((*Block: next 2 statements*)
			let VP_store := update VP_store "VP_result" (VInteger ( get_int VP_store "VP_I" )) in
			let VP_broken := true in VP_store) 
else
 	((*nothing and mid-seq*) VP_store) in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) in loop 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" linear_search.

Definition binary_search (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_L" (VInteger ( 0 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_R" (VInteger ( get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (VInteger ( -1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let loop := (fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 		 match VP_depth with 
 			 | O => None
			 | S n' => if (get_int VP_store "VP_L" <=? get_int VP_store "VP_R") then
 			 (let VP_store := ((*Block: next 3 statements*)
		let VP_store := update VP_store "VP_M" (VInteger ( get_int VP_store "VP_L" + get_int VP_store "VP_R" - get_int VP_store "VP_L" / 2 )) in
		let VP_store := if (subscript (get_array VP_store "VP_ARR") (get_int VP_store "VP_M") 0 =? get_int VP_store "VP_KEY") then
 	 ((*Block: next 2 statements*)
		let VP_store := update VP_store "VP_result" (VInteger ( get_int VP_store "VP_M" )) in
		let VP_broken := true in VP_store) 
else
 	((*nothing and mid-seq*) VP_store) in
		let VP_store := if (subscript (get_array VP_store "VP_ARR") (get_int VP_store "VP_M") 0 <? get_int VP_store "VP_KEY") then
 	 (update VP_store "VP_L" (VInteger ( get_int VP_store "VP_M" + 1 ))) 
else
 	(update VP_store "VP_R" (VInteger ( get_int VP_store "VP_M" - 1 ))) in) in loop n' VP_broken VP_store) 
		else
 			(Some VP_store)
			 		 end) in loop 1000%nat false VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" binary_search.

Definition main (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := get_array (setlength VP_store 100 (get_array VP_store "VP_ARR")) "VP_result" in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result" in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 0 )) in
			let loop := (fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") (get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result")) then
 				 (let VP_store := (let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)ARR" (VInteger ( get_int (Random VP_store 1000) "VP_result" )) in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) in loop 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_KEY" (VInteger ( subscript (get_array VP_store "VP_ARR") 50 0 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update_record VP_store "VP_SORTED" (bubble_sort VP_store (get_array VP_store "VP_ARR")) "VP_result",VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_I" (VInteger ( get_int (linear_search VP_store (get_int VP_store "VP_KEY") (get_array VP_store "VP_SORTED")) "VP_result" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 6 statements*)
	let VP_store := fpc_write_text_shortstr VP_store ("Linear search:") 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store ("  Key:        ") 0 in
	let VP_store := fpc_write_text_sint VP_store (get_int VP_store "VP_KEY") 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store ("  Index:      ") 0 in
	let VP_store := fpc_write_text_uint VP_store (get_int VP_store "VP_I") 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store ("  arr[index]: ") 0 in
	let VP_store := fpc_write_text_sint VP_store (subscript (get_array VP_store "VP_SORTED") (get_int VP_store "VP_I") 0) 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_I" (VInteger ( get_int (binary_search VP_store (get_int VP_store "VP_KEY") (get_array VP_store "VP_SORTED")) "VP_result" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 6 statements*)
	let VP_store := fpc_write_text_shortstr VP_store ("Binary search:") 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store ("  Key:        ") 0 in
	let VP_store := fpc_write_text_sint VP_store (get_int VP_store "VP_KEY") 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store ("  Index:      ") 0 in
	let VP_store := fpc_write_text_uint VP_store (get_int VP_store "VP_I") 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
	let VP_store := fpc_write_text_shortstr VP_store ("  arr[index]: ") 0 in
	let VP_store := fpc_write_text_sint VP_store (subscript (get_array VP_store "VP_SORTED") (get_int VP_store "VP_I") 0) 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" $main.

Compute (main fresh_store).