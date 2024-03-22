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

Definition factorial (VP_store: store) loop_limit := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (VInteger ( 1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
			match 
				while ( fun VP_store => 1 <=? get_int VP_store "VP_X" ) with VP_store upto loop_limit begin fun VP_store => (*Block: next 2 statements*)
					let VP_store := update VP_store "VP_result" (VInteger ( get_int VP_store "VP_result" * get_int VP_store "VP_X" )) in
					update VP_store "VP_X" (VInteger ( get_int VP_store "VP_X" - 1 )) 
				end
			with 
			| None => (VP_store, true)
			| Some s => (s, VP_poison)
			end
		else
 			(VP_store,true)) in
	(VP_store, VP_poison).

Definition output_safe (f : store -> nat -> store * bool) 
		input expected :=
	forall loop_limit output, 
		(output, false) = f input loop_limit -> output "VP_result" = expected.

Ltac vpex_term term := 
	match term with [(?fst, ?snd) = 
			match ?m with (Some s) => ?s' | None => ?n' end] => idtac s
	end.

Ltac vpex :=
	match goal with [H: (?fst, ?snd) = 
		match ?m with (Some s) => ?s' | None => ?n' end |- _] =>
			let name := fresh "body" in
			remember m as name
		| [H: (?fst, ?snd) = (let (st, ps) := 
			match ?m with (Some s) => ?s' | None => ?n' end in _) |- _] =>
			let E := fresh "E" in 
			destruct m eqn:E
	end || idtac "No match".

Require Import FunctionalExtensionality.

Lemma update_shadow : forall (m : store) x v1 v2,
  (x !-> v2 ; x !-> v1 ; m) = (x !-> v2 ; m).
Proof.
  intros. apply functional_extensionality. intros.
  unfold update. destruct (String.eqb x0 x) eqn:E; reflexivity.
Qed.

Lemma update_eq : forall (m : store) x v,
	(x !-> v; m) x = v.
Proof.
	intros. unfold update. now rewrite String.eqb_refl.
Qed.

Lemma update_neq : forall (m : store) x y v,
	x <> y ->
	(x !-> v; m) y = m y.
Proof.
	intros. unfold update. destruct (eqb_neq x y). now rewrite String.eqb_sym, (H1 H).
Qed.

Theorem update_permute : 
  forall (m : store)
    v1 v2 x1 x2,
  x2 <> x1 ->
  (x1 !-> v1 ; x2 !-> v2 ; m)
  =
  (x2 !-> v2 ; x1 !-> v1 ; m).
Proof.
  intros. apply functional_extensionality. intros.
  unfold update. destruct (x =? x1)%string eqn:E, (x =? x2)%string eqn:E'; auto.
  pose (String.eqb_eq x x1). pose (String.eqb_eq x x2).
  destruct i, i0. specialize (H0 E). specialize (H2 E'). subst. contradiction.
Qed.

Definition Z_fact (n : Z) := Z.of_nat (fact (Z.to_nat n)).

Lemma fact_sub : forall n,
	(1 <= n)%nat ->
	fact n = (n * fact (n - 1))%nat.
Proof.
	induction n; intros; simpl in *.
	inversion H. now rewrite Nat.sub_0_r.
Qed.

Require Import Lia.

Lemma Z_fact_sub : forall n,
	1 <= n ->
	Z_fact n = n * Z_fact (n - 1).
Proof.
	intros. replace n with (Z.of_nat (Z.to_nat n)).
	unfold Z_fact. rewrite Nat2Z.id. 
		replace (Z.of_nat (Z.to_nat n) - 1) with (Z.of_nat (Z.to_nat (n - 1))). 
		rewrite Nat2Z.id. 
		rewrite <- Nat2Z.inj_mul, Z2Nat.inj_sub. replace (Z.to_nat 1) with 1%nat. 
		rewrite fact_sub; lia. all: lia.
Qed.

Lemma nle_1_destruct : forall n,
	~ (1 <= n) ->
	n = 0 \/ exists p, n = Z.neg p.
Proof.
	intros.	destruct n; try lia.
	right. now exists p.
Qed.

Lemma Z_fact_nle_1 : forall n,
	(1 <=? n) = false ->
	Z_fact n = 1.
Proof.
	intros. apply Z.leb_nle in H. apply nle_1_destruct in H. destruct H; subst.
	reflexivity. destruct H. subst. reflexivity.
Qed.

Theorem factorial_correct : forall n,
	output_safe factorial ("VP_X" !-> VInteger n; fresh_store) (VInteger (Z_fact n)).
Proof.
	intros n loop_limit output Terminates. unfold factorial in Terminates. simpl in Terminates.
		vpex. inversion Terminates; subst; clear Terminates. 
		generalize dependent s. replace (Z_fact n) with (1 * Z_fact n).
		generalize dependent n. generalize 1 at 3 4 as inter_prod.
		induction loop_limit; intros.
			inversion E. match goal with [H: forall i n s, ?x ?l ?b ?store = _ -> _ |- _] => 
				remember x as loop_body end.
			simpl in *. unfold get_int in E.
				rewrite update_neq, update_eq, update_eq, update_neq, update_neq, update_eq in E;
					try discriminate. destruct (1 <=? n) eqn:E0.
			rewrite update_shadow, update_permute, update_shadow in E; try discriminate.
			rewrite (IHloop_limit _ _ _ E).
			rewrite Heqloop_body in E. destruct loop_limit. inversion E. simpl in E.
			unfold get_int in E. rewrite update_eq in E.
			rewrite <- Z.mul_assoc, <- Z_fact_sub. reflexivity. lia.
			inversion E; subst. rewrite update_eq.
			rewrite (Z_fact_nle_1 _ E0). now rewrite Z.mul_1_r. lia.
		inversion Terminates.
Qed.
