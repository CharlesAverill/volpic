(*Preamble*)
Require Import Volpic_preamble.
Require Import Volpic_notation.
Require Import String.
Require Import ZArith.
Require Import List.
Require Import Bool.
Open Scope string_scope.
Open Scope Z_scope.
Open Scope volpic_notation.
Import ListNotations.


Definition factorial (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (VInteger ( 1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (while ( fun VP_store => 1 <=? get_int VP_store "VP_X" ) with VP_store upto 1000%nat begin fun VP_store => (*Block: next 2 statements*)
		let VP_store := update VP_store "VP_result" (VInteger ( get_int VP_store "VP_result" * get_int VP_store "VP_X" )) in
update VP_store "VP_X" (VInteger ( get_int VP_store "VP_X" - 1 )) end,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.

Definition main (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 6 statements*)
(*	let VP_store := fpc_write_text_shortstr VP_store ("n: ") 0 in*)
(*	let VP_store := fpc_write_end VP_store in*),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 6 statements*)
(*	let VP_store := fpc_read_text_shortstr VP_store 255 (get_string VP_store "VP_I") in*)
(*	let VP_store := fpc_readln_end VP_store in*),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_N" (VInteger ( get_int (StrToInt VP_store (get_string VP_store "VP_I")) "VP_result" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 7 statements*)
(*	let VP_store := fpc_write_text_shortstr VP_store ("fact(n): ") 0 in*)
(*	let VP_store := fpc_write_text_sint VP_store (get_int (factorial VP_store (get_int VP_store "VP_N")) "VP_result") 0 in*)
(*	let VP_store := fpc_writeln_end VP_store in*),VP_poison) 
		else
 			(VP_store,true)) in
VP_store.

Compute (main fresh_store).