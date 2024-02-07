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
Require Import Vector.
Import VectorNotations.

Print List.nth.
Print Vector.t.



Definition print_arr {n : nat} (VP_store: store) (vec : vector Z n) := 
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
(let going_up := 0 <? get_int (fpc_dynarray_high VP_store vec) "VP_result" in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 0 )) in
(fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") (get_int (fpc_dynarray_high VP_store vec) "VP_result")) then
 				 (let VP_store := ((*Block: next 2 statements*)
(*Block: next 6 statements*)
			let VP_store := fpc_write_text_ansistr VP_store ((IntToStr VP_store (subscript vec (Z.to_nat (get_int VP_store "VP_I")) 0))) in
			let VP_store := fpc_write_end VP_store in
			let VP_store := if (get_int VP_store "VP_I" !=? get_int (fpc_dynarray_high VP_store vec) "VP_result") then
 	 ((*Block: next 6 statements*)
			let VP_store := fpc_write_text_shortstr VP_store (", ") in
			let VP_store := fpc_write_end VP_store in VP_store) 
else
 	VP_store in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
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
 			 ((*Block: next 6 statements*)
	let VP_store := fpc_write_text_char VP_store 93 0 in
	let VP_store := fpc_writeln_end VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.

Theorem test : forall x y, (x <? y)%nat = true -> vector Z (x + (y - x))%nat -> vector Z y.
intros. rewrite Arith_prebase.le_plus_minus_r_stt in X. exact X. 
apply Nat.ltb_lt in H. now apply Nat.lt_le_incl in H. Defined.

Require Import Lia.

Definition setlength (s : store) (id : string) (new_len : nat) 
	{old_len : nat} (old_vec : vector Z old_len) : store.
	destruct (old_len <? new_len)%nat eqn:E.
	- remember (append old_vec (pad_vec (new_len - old_len) 0)) as new_vec.
	  assert (t Z new_len). {
	 	exact (test old_len new_len E new_vec). 
	  } exact (update s id (VArray Z new_len H)).
	- remember (int_array_take new_len old_vec) as new_vec. 
	  exact (update s id (VArray Z new_len new_vec)).
Defined.

Definition bubble_sort (VP_store: store) {arr_len : nat} (vec : vector Z arr_len) := 
	let VP_poison := false in
	(* let (VP_store, VP_poison) :=
		if (negb VP_poison) then (
			(setlength VP_store "VP_result" (array_size vec) (get_array VP_store "VP_result"), VP_poison)
		) else (VP_store,true) in *)
	let VP_store := update VP_store "VP_result" (VArray Z arr_len vec) in
	(* Loop 1 *)
	(* let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? get_int (fpc_dynarray_high VP_store vec) "VP_result" in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 0 )) in
(fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") (get_int (fpc_dynarray_high VP_store vec) "VP_result")) then
 				 (let VP_store := (let VP_store := update VP_store (* This is a vecn id_of_parse_tree, something's gonna go wrong *)"VP_result" (VInteger ( subscript vec (Z.to_nat (get_int VP_store "VP_I")) 0 )) in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end)
		else
 			(VP_store,true)) in *)
	(* Outer loop *)
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_result")) "VP_result" - 1 <? 0 in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_result")) "VP_result" - 1 )) in
		(* Inner loop*)
		(fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
			match VP_depth with 
				| O => None
				| S n' => if (bounds_op (get_int VP_store "VP_I") 0) then
				(let VP_store := (let going_up := 0 <? get_int VP_store "VP_I" in
			let bounds_op := (if going_up then Z.leb else Z.geb) in
			let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
			let VP_store := update VP_store "VP_J" (VInteger ( 0 )) in
			let (VP_store,VP_poison) :=
			match
			((fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
							match VP_depth with 
								| O => None
								| S n' => if (bounds_op (get_int VP_store "VP_J") (get_int VP_store "VP_I")) then
								(let VP_store := (let VP_store := if (subscript (get_array VP_store "VP_result") (Z.to_nat (get_int VP_store "VP_J")) 0 >? subscript (get_array VP_store "VP_result") (Z.to_nat (get_int VP_store "VP_J" + 1)) 0) then
				(*Block: next 3 statements*)
							let VP_store := update VP_store "VP_TEMP" (VInteger ( subscript (get_array VP_store "VP_result") (Z.to_nat (get_int VP_store "VP_J")) 0 )) in
							let VP_store := update VP_store "VP_result" 
								(VArray Z arr_len (
									(* Vector.replace_order (get_array VP_store "VP_result")) *)
									vec
								))
								(* (VInteger ( subscript (get_array VP_store "VP_result") (Z.to_nat (get_int VP_store "VP_J" + 1)) 0 ))  *)
							in
			update VP_store "VP_result" (VInteger ( get_int VP_store "VP_TEMP" )) 
			else
				((*nothing and mid-seq*) VP_store) in
						let VP_store := update VP_store "VP_J" (VInteger (iter_op (get_int VP_store "VP_J"))) in VP_store) in loop n' VP_broken VP_store) 
							else
								(Some VP_store)
												end) 30%nat false VP_store) with
			| None => (VP_store,true)
			| Some VP_store' => (VP_store', VP_poison)
			end in
		(* Outer loop increment *)
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) 30%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" bubble_sort.

(* Compute get_array (bubble_sort fresh_store [2;1]) "VP_result".

Compute get_int (fpc_dynarray_high (bubble_sort fresh_store [5;3;2;1;6;8;2]) [5;3;2;1;6;8;2]) "VP_result".

(* Why doesn't this return lol *)
Compute sf_get (bubble_sort fresh_store [5;3;2;1;6;8;2]) "VP_I". *)

Definition simple_loop (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? 10 in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 0 )) in
(fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") 10) then
 				 (let VP_store := ((*Block: next 6 statements*)
			let VP_store := fpc_write_text_uint VP_store (get_int VP_store "VP_I") 0 in
			let VP_store := fpc_writeln_end VP_store in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) 1000%nat false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" simple_loop.

Definition linear_search (VP_store: store) (loop_limit : nat) {arr_len : nat} (vec : vector Z arr_len) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (VInteger ( -1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 0 <? Z.of_nat arr_len in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 0 )) in
(fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") (get_int (fpc_dynarray_high VP_store vec) "VP_result")) then
 				 (let VP_store := (let VP_store := if (subscript vec (Z.to_nat (get_int VP_store "VP_I")) 0 =? get_int VP_store "VP_KEY") then
 	 ((*Block: next 2 statements*)
			let VP_store := update VP_store "VP_result" (VInteger ( get_int VP_store "VP_I" )) in
			let VP_broken := true in VP_store) 
else
 	((*nothing and mid-seq*) VP_store) in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
			else
 				(Some VP_store)
				 			 end) loop_limit false VP_store) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" linear_search.

Compute get_int (linear_search (update fresh_store "VP_KEY" (VInteger 3)) 10 [1;2;3;4;5]) "VP_result".
Compute get_int (linear_search (update fresh_store "VP_KEY" (VInteger 3)) 10 []) "VP_result".

Inductive list_search {A : Type} : list A -> A -> nat -> Prop :=
  | sc_hd : forall (x : A) (xs : list A),
      list_search (x :: xs) x 0
  | sc_tl : forall (x y : A) (xs : list A) (n : nat),
      list_search xs x n -> list_search (y :: xs) x (S n).

Definition vector_search_correct {T : Type} {n : nat} (vec : vector T n) :=
	list_search (Vector.to_list vec).

Fixpoint vec_find {T : Type} {n : nat} (vec : vector T n) (key : T) 
	(eq : forall n m : T, {n = m} + {n <> m}) : option nat :=
	match vec with
	| [] => None
	| h :: t => if eq h key then Some O else (
		match vec_find t key eq with
		| None => None
		| Some n' => Some (S n')
		end
	)
	end.

Theorem vec_find_correct : 
	forall T n (vec : vector T n) key eq idx
	(FOUND : vec_find vec key eq = Some idx),
	vector_search_correct vec key idx.
Proof.
	induction vec; intros; 
		unfold vector_search_correct in *; simpl in *.
	- inversion FOUND.
	- destruct (eq h key).
		-- inversion FOUND; subst. constructor.
		-- destruct (vec_find vec key eq) eqn:E; inversion FOUND; subst.
			apply sc_tl, IHvec with (eq := eq), E.
Qed.

Lemma get_int_update : 
	forall (s : store) (x : Z) (id : string),
	get_int (update s id (VInteger x)) id = x.
Proof.
	intros. unfold update, get_int, sf_get.
	simpl. rewrite String.eqb_refl. reflexivity.
Qed.

Require Import FunctionalExtensionality.

Check functional_extensionality.

Lemma vsc_false_for_nil :
	forall (T : Type) key idx,
	~ (@vector_search_correct T 0 [] key idx).
Proof.
	intros. intro. inversion H.
Qed.

(* Theorem mwe : 
	forall loop_limit max_i,
	0 < max_i ->
	max_i < (Z.of_nat loop_limit) ->
	(fix loop loop_limit store :=
		match loop_limit with
		| O => None
		| S n' => (
			(* Loop condition *)
			if (get_int store "I" >=? max_i) then 
				(* Loop terminates *)
				Some store
			else (
				(* Loop body *)
				let store' :=
					update store "I" (VInteger (get_int store "I" + 1)) 
				in loop n' store'
			)
		)
		end
	) loop_limit (update fresh_store "I" (VInteger 0)) <> None.
Proof.
	induction loop_limit; intros; simpl in *.
	- lia.
	- rewrite get_int_update. rewrite Z.geb_leb. 
		apply Zlt_compare in H. destruct (0 ?= max_i) eqn:E. lia.
		apply -> Z.compare_lt_iff in E. destruct (max_i <=? 0).
		intro H1; inversion H1.  *)

Theorem update_cancel :
	forall (s: store) x y1 y2,
		update (update s x y1) x y2 = update s x y2.
Proof.
	intros. apply functional_extensionality. intro z. unfold update.
	destruct (z =? x)%string; reflexivity.
Qed.

Theorem update_frame :
  forall (s: store) x y z (NE: z<>x),
  update s x y z = s z.
Proof.
  intros. unfold update. destruct (z =? x)%string eqn:E.
    exfalso. apply NE, String.eqb_eq. assumption.
    reflexivity.
Qed.

Definition linear_search' (VP_store: store) (loop_limit : nat) {arr_len : nat} (vec : vector Z arr_len) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (VInteger ( -1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := true in
		let bounds_op := Z.leb in
		let iter_op := Z.add 1 in
(fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) (i : Z) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (negb VP_broken) && (bounds_op i (get_int (fpc_dynarray_high VP_store vec) "VP_result")) then
 				 (let VP_store := (let VP_store := if (subscript vec (Z.to_nat i) 0 =? get_int VP_store "VP_KEY") then
 	 ((*Block: next 2 statements*)
			let VP_store := update VP_store "VP_result" (VInteger i) in
			let VP_broken := true in VP_store) 
else
 	((*nothing and mid-seq*) VP_store) in VP_store) in loop n' VP_broken VP_store (iter_op i)) 
			else
 				(Some VP_store)
				 			 end) loop_limit false VP_store 0) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
(VP_store,VP_poison).

Theorem linear_search'_correct_pascal :
	forall (loop_limit : nat) (s s' : store) (key : Z) (len : nat) 
		(vec : vector Z len) (Zidx : Z) poison,
	poison = false ->
	((s', poison) = linear_search' (update s "VP_KEY" (VInteger key)) loop_limit vec) ->
	(Zidx = get_int s' "VP_result") ->
	(0 <= Zidx) ->
	vector_search_correct vec key (Z.to_nat Zidx).
Proof.
	intros loop_limit s s' key len vec. revert loop_limit s s' key. 
		induction vec; intros loop_limit s s' key Zidx poison PFALSE OUT IDX ZLTIDX;
		unfold linear_search' in OUT; simpl in *.
	- unfold fpc_dynarray_high in OUT. unfold get_int at 1 in OUT.
		unfold sf_get in OUT. simpl in OUT. destruct loop_limit in OUT.
			-- inversion OUT; subst; contradiction.
			-- simpl in OUT. inversion OUT; subst. 
				rewrite get_int_update in ZLTIDX. lia.
	- unfold fpc_dynarray_high in OUT. unfold get_int at 1 in OUT.
		unfold sf_get in OUT. simpl in OUT. 
Abort.



(* Definition binary_search (VP_store: store) := 
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
 			 ((fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
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
			 		 end) 1000%nat false VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "algorithms.ml" binary_search. *)

(* Definition main (VP_store: store) := 
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
(fix loop (VP_depth : nat) (VP_broken : bool) (VP_store : store) := 
 			 match VP_depth with 
 				 | O => None
				 | S n' => if (bounds_op (get_int VP_store "VP_I") (get_int (fpc_dynarray_high VP_store (get_array VP_store "VP_ARR")) "VP_result")) then
 				 (let VP_store := (let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)ARR" (VInteger ( get_int (Random VP_store 1000) "VP_result" )) in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store) in loop n' VP_broken VP_store) 
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
Extraction "algorithms.ml" $main. *)

(* Compute (main fresh_store). *)
