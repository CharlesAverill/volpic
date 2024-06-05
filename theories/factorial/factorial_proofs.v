Require Import Volpic_preamble.
Require Import Volpic_notation.
Require Import FunctionalExtensionality.
Require Import Lia.
Open Scope string_scope.
Open Scope Z_scope.
Open Scope volpic_notation.

Require Import factorial.

Definition Z_fact (n : Z) := Z.of_nat (fact (Z.to_nat n)).

Lemma fact_sub : forall n,
	(1 <= n)%nat ->
	fact n = (n * fact (n - 1))%nat.
Proof.
	induction n; intros; simpl in *.
	inversion H. now rewrite Nat.sub_0_r.
Qed.

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

Definition output_safe (f : store -> nat -> store * bool) 
		input expected :=
	forall loop_limit output
	  (Terminates: (output, false) = f input loop_limit),
	  output "VP_result" = expected.

Ltac vpex :=
	match goal with [H: (?fst, ?snd) = 
		match ?m with (Some s) => ?s' | None => ?n' end |- _] =>
			let name := fresh "body" in
			remember m as name
		| [H: (?fst, ?snd) = (let (st, ps) := 
			match ?m with (Some s) => ?s' | None => ?n' end in _) |- _] =>
			let E := fresh "Eq" in 
			destruct m eqn:E
	end || idtac "No match".

Theorem factorial_correct : forall n st,
	output_safe factorial ("VP_X" !-> VInteger n; st) (VInteger (Z_fact n)).
Proof.
	unfold output_safe. intros. 
	(* 
		When dealing with fixpoints, we almost always want to induct over their
		decreasing argument, because this will "turn the crank" and evaluate another
		iteration of the loop.

		There's an issue though: if we induct too early over
		the decreasing argument (loop_limit in VOLPIC-lifted code), we end up with
		an inductive hypothesis that refers to code outside of the fixpoint. This is
		no good, because it generally ends up over-specializing our assumptions,
		making them unusable.

		The solution is to simplify until we get to just the loop in our termination
		hypothesis. Note: this technique will need more refinement if there is code
		after the loop.
	*)
	unfold factorial in Terminates. simpl in Terminates.
	(*
		We end up with a termination hypothesis that looks like
			(output, false) := (let (VP_store, VP_poison) := <code> in (VP_store, VP_poison)).

		This is annoying, because we can't use `inversion` or `simpl` to do any 
		of the substitution that would seem intuitive at this point.

		The `vpex` tactic looks for patterns like these and destructs the <code> terms,
		unfolding the `let _ := _ in _` notation, making it much easier to 
		write sub-proofs about them.
	*)
	vpex; inversion Terminates. subst. clear Terminates.
	(*
		We will often need some clever generalizations in proofs such as these.
		These loosely resemble loop invariants that we'd have to write if we were
		dealing with the same code in an imperative model using Hoare logic.
	*)
	replace (Z_fact n) with (1 * Z_fact n) by lia. 
		generalize dependent n. generalize 1 at 3 4 as inter_prod.
	(* 
		Finally - we can do our induction. We will always get a trivial case where
		the loop limit is zero, causing an early termination, which poisons the store.
	*)
	induction loop_limit; intros. inversion Eq.
	match goal with [H: forall i n, ?x ?l ?b ?store = _ -> _ |- _] => 
		remember x as loop_body end.
	(* We can now start to reduce some of the assignments that have built up *) 
	unfold get_int in Eq.
	rewrite update_neq, update_eq, update_eq, update_neq, update_neq, update_eq in Eq;
		try discriminate.
	(* We have a conditional value for our output store, so let's do a case analysis *)
	destruct (1 <=? n) eqn:E.
	- rewrite update_shadow, update_permute, update_shadow in Eq; try discriminate.
		(* Now we see why we generalized before inducting *)
		erewrite IHloop_limit. rewrite <- Z.mul_assoc, <- Z_fact_sub.
			reflexivity. lia. assumption.
	- inversion Eq; subst. rewrite update_eq.
		now rewrite Z_fact_nle_1, Z.mul_1_r.
Qed.
