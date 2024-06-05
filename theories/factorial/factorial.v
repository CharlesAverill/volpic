(*Preamble*)
Require Import Volpic_preamble.
Require Import Volpic_notation.
Require Export String.
Require Export ZArith.
Require Export List.
Require Export Bool.
Open Scope string_scope.
Open Scope Z_scope.
Open Scope volpic_notation.
Import ListNotations.


Definition factorial (VP_store: store) (VP_loop_limit: nat) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (VInteger ( 1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (match 
(while ( fun VP_store => 1 <=? get_int VP_store "VP_X" ) with VP_store upto VP_loop_limit begin fun VP_store => (*Block: next 2 statements*)
			let VP_store := update VP_store "VP_result" (VInteger ( get_int VP_store "VP_result" * get_int VP_store "VP_X" )) in
update VP_store "VP_X" (VInteger ( get_int VP_store "VP_X" - 1 )) end) with 
 		 | None => (VP_store,true)
		 | Some VP_store' => (VP_store',VP_poison)
		 	 end) 
		else
 			(VP_store,true)) in
(VP_store,VP_poison).

(*Ignored $main*)