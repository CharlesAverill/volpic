(*Preamble*)
Require Import Volpic_preamble.
Require Import Volpic_notation.
Require Import String.
Require Import ZArith.
Require Import List.
Require Import Bool.
Require Import ExtrOcamlBasic.
Require Import ExtrOcamlString.
Extraction Language OCaml.
Open Scope string_scope.
Open Scope Z_scope.
Open Scope volpic_notation.
Import ListNotations.

Definition string_subscript (s : string) (idx : Z) : Z :=
	match String.get (Z.to_nat idx) s with 
	| None => -1
	| Some a => Z.of_nat (Ascii.nat_of_ascii a)
	end.

Definition ispalindrome (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (VInteger ( 1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_LEN" (VInteger (Z.of_nat (String.length (get_string VP_store "VP_STR")))),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(let going_up := 1 <? get_int VP_store "VP_LEN" / 2 in
		let bounds_op := (if going_up then Z.leb else Z.geb) in
		let iter_op := (if going_up then (Z.add 1) else (Z.sub 1)) in
		let VP_store := update VP_store "VP_I" (VInteger ( 1 )) in
while ( fun VP_store => bounds_op (get_int VP_store "VP_I") (get_int VP_store "VP_LEN" / 2) ) with VP_store upto 1000%nat begin fun VP_store => 			
let VP_store := if (string_subscript (get_string VP_store "VP_STR") (get_int VP_store "VP_I") !=? string_subscript (get_string VP_store "VP_STR") (get_int VP_store "VP_LEN" - get_int VP_store "VP_I" + 1)) then
 	 ((*Block: next 2 statements*)
			let VP_store := update VP_store "VP_result" (VInteger ( 0 )) in
			let VP_broken := true in VP_store) 
else
 	((*nothing and mid-seq*) VP_store) in
		let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store end) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
VP_store.

Compute ispalindrome (update fresh_store "VP_STR" (VString "aa")) "VP_result".

Extraction "palindrome.ml" ispalindrome.

(*Failed to convert $main: Couldn't find key "value" in data list*)

Compute (main fresh_store).
