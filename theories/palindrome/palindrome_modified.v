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
	match String.get (Z.to_nat idx - 1) s with 
	| None => -1
	| Some a => Z.of_nat (Ascii.nat_of_ascii a)
	end.

Definition ispalindrome (VP_store: store) loop_limit := 
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
		(if (negb VP_poison) then
 			 (match 
		(let going_up := 1 <? get_int VP_store "VP_LEN" / 2 in
		let bounds_op := Z.leb in
		let iter_op := Z.add 1 in
		let VP_store := update VP_store "VP_I" (VInteger ( 1 )) in
			while ( fun VP_store => bounds_op (get_int VP_store "VP_I") (get_int VP_store "VP_LEN" / 2) ) with VP_store upto loop_limit 
			begin fun VP_store => 
			(* VP_result = 1 /\ VP_I <= VP_LEN / 2*)
			let VP_store := if (string_subscript (get_string VP_store "VP_STR") (get_int VP_store "VP_I") !=? string_subscript (get_string VP_store "VP_STR") (get_int VP_store "VP_LEN" - get_int VP_store "VP_I" + 1)) then
				((*Block: next 2 statements*)
						let VP_store := update VP_store "VP_result" (VInteger ( 0 ))in
						let VP_broken := true in VP_store) 
			else
				((*nothing and mid-seq*) VP_store) in
					let VP_store := update VP_store "VP_I" (VInteger (iter_op (get_int VP_store "VP_I"))) in VP_store 
			end) 
		(* VP_result = 1 /\ ~ (VP_I <= VP_LEN / 2) *)
		with
 		 | None => (VP_store,true)
		 | Some VP_store => (VP_store,VP_poison)
		 	 end) 
		else
 			(VP_store,true)).

Compute fst (ispalindrome (update fresh_store "VP_STR" (VString "aaa")) 1) "VP_result".

Extraction "palindrome.ml" ispalindrome.

Require Import Ascii.

Inductive pal : string -> Prop :=
| pal_nil : pal EmptyString
| pal_single : forall (x : ascii), pal (String x EmptyString)
| pal_ht : forall (h : ascii) (t : string), 
	pal t -> pal ((String h t) ++ (String h EmptyString)).

Definition reverse (s : string) :=
	string_of_list_ascii (rev (list_ascii_of_string s)).

Lemma string_of_list_ascii_distr : forall l1 l2,
	string_of_list_ascii (l1 ++ l2) = 
		string_of_list_ascii l1 ++ string_of_list_ascii l2.
Proof.
	induction l1; intros; auto.
	simpl in *. now rewrite IHl1.
Qed.

Lemma rev_String : forall a s,
	reverse (String a s) = reverse s ++ (String a EmptyString).
Proof.
	intros. generalize dependent a.
	induction s; simpl in *; intros.
	reflexivity.
	rewrite IHs; simpl in *. unfold reverse; simpl.
	now repeat rewrite string_of_list_ascii_distr; simpl.
Qed.

Lemma String_app_assoc : forall a s1 s2,
	String a (s1 ++ s2) = (String a s1) ++ s2.
Proof.
	intros. destruct s1; reflexivity.
Qed.

Lemma app_assoc : forall s1 s2 s3,
	s1 ++ (s2 ++ s3) = (s1 ++ s2) ++ s3.
Proof.
	induction s1; intros; simpl in *.
	reflexivity.
	now rewrite IHs1.
Qed.

Theorem pal_app_rev : forall (s : string),
  pal (s ++ (reverse s)).
Proof.
    induction s; simpl.
    constructor.
	rewrite rev_String. replace (String a (s ++ reverse s ++ String a "")) with 
		(String a (s ++ reverse s) ++ String a ""). now constructor.
	now rewrite String_app_assoc, <- app_assoc, <- String_app_assoc.
Qed.

Lemma app_empty_r : forall s,
	s ++ "" = s.
Proof.
	induction s; simpl.
	reflexivity. now rewrite IHs.
Qed.

Lemma reverse_app_distr : forall s1 s2,
	reverse (s1 ++ s2) = reverse s2 ++ reverse s1.
Proof.
	induction s1; intros; simpl in *. 
	unfold reverse at 3. simpl. now rewrite app_empty_r.
	rewrite String_app_assoc, rev_String, app_assoc, <- IHs1.
	unfold reverse; simpl. now rewrite string_of_list_ascii_distr.
Qed.

Theorem pal_rev : forall (s: string), 
    pal s -> s = reverse s.
Proof.
    intros. induction H; simpl in *; try reflexivity.
    now rewrite rev_String, reverse_app_distr, <- IHpal.
Qed.

Lemma palindrome_cons : forall x s,
    pal s -> pal ((String x s) ++ (String x "")).
Proof.
    induction s; intros.
    - apply pal_app_rev.
    - now apply pal_ht.
Qed.

Lemma split_last : forall s, 
    s = "" \/ exists x p, s = p ++ (String x "").
Proof.
    induction s.
    - now left.
    - right. destruct IHs; subst.
        -- now exists a, "".
        -- destruct H, H; subst. now exists x, (String a x0).
Qed.

Require Import Nat.

Lemma length_app_distr : forall s1 s2,
	String.length (s1 ++ s2) = (String.length s1 + String.length s2)%nat.
Proof.
	induction s1; intros; simpl in *.
	reflexivity.
	now rewrite IHs1.
Qed.

Theorem plus_le : forall n1 n2 m,
    (n1 + n2 <= m)%nat ->
    (n1 <= m)%nat /\ (n2 <= m)%nat.
Proof.
    induction n1; intros; split.
    apply Nat.le_0_l. assumption.
    apply (Nat.le_trans _ (S n1 + n2) _).
    apply Nat.le_add_r. assumption.
    apply (Nat.le_trans _ (S n1 + n2) _).
    rewrite Nat.add_comm. apply Nat.le_add_r. assumption.
Qed.

Lemma length_app_le :
    forall s1 s2 n,
    (String.length (s1 ++ s2) <= n)%nat ->
    (String.length s1 <= n)%nat /\ (String.length s2 <= n)%nat.
Proof.
    induction s1; intros;
        try rewrite app_length in *; simpl in *; split.
    - apply Nat.le_0_l.
    - assumption.
    - rewrite length_app_distr, Nat.add_comm, plus_n_Sm in H. 
		apply plus_le in H. now destruct H.
	- rewrite length_app_distr, Nat.add_comm, plus_n_Sm in H.
		apply plus_le in H. now destruct H.
Qed.

Lemma app_nil :
    forall s1 s2,
    "" = s1 ++ s2 -> s1 = "" /\ s2 = "".
Proof.
    induction s1; intros; simpl in *; split.
    - reflexivity.
    - symmetry. assumption.
    - inversion H.
    - inversion H.
Qed.

Lemma cons_inj : 
    forall s1 s2 x,
    s1 = s2 -> (String x s1) = (String x s2).
Proof.
    destruct s1; intros; now rewrite H. 
Qed.

Lemma app_single_end :
    forall x s1 s2,
    s1 ++ (String x "") = s2 ++ (String x "") -> s1 = s2.
Proof.
    induction s1; intros; simpl in *.
    - destruct s2. reflexivity.
        inversion H; subst.
        destruct (app_nil s2 (String a "") H2); subst.
        now symmetry.
    - destruct s2; simpl in *.
        inversion H; subst. 
        symmetry in H2. 
        destruct (app_nil s1 (String x "") H2); subst.
        inversion H1. inversion H.
        now apply cons_inj, IHs1.
Qed.

Lemma length_0_nil: forall s,
    String.length s = 0%nat -> s = EmptyString.
Proof.
    destruct s. reflexivity. intro. inversion H.
Qed.

Lemma palindrome_step : 
    forall n s,
    (String.length s <= n)%nat -> s = reverse s -> pal s.
Proof.
    induction n; intros.
    - inversion H. rewrite (length_0_nil s H2).
        apply pal_nil.
    - destruct s as [| hd tl]. 
        -- apply pal_nil.
        -- destruct (split_last tl); subst.
            apply pal_single.
            destruct H1 as [last], H1 as [mid]; subst.
            simpl in *. apply le_S_n in H.
			rewrite rev_String, reverse_app_distr in H0; simpl in *.
            inversion H0. apply pal_ht.
            apply IHn. apply length_app_le in H.
            now destruct H.
            now apply app_single_end in H3.
Qed.

Theorem palindrome_converse: forall s,
    s = reverse s -> pal s.
Proof.
    intros. apply (palindrome_step (String.length s) s). 
    subst. apply le_n.
    assumption.
Qed.

Require Import Lia.
Require Import BinPosDef.
(* Open Scope positive_scope. *)

(* Eval unfold ispalindrome in ispalindrome. *)

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

Lemma get_string_eq : forall m x v,
	get_string (x !-> VString v; m) x = v. Admitted.

Lemma get_int_eq : forall m x v,
	get_int (x !-> VInteger v; m) x = v. Admitted.

Lemma eqb_neq : forall (s1 s2 : string),
	s1 <> s2 <-> (s1 =? s2)%string = false.
Proof.
	split; generalize dependent s2; induction s1; intros.
	- destruct s2. now contradict H. reflexivity.
	- destruct s2. reflexivity. destruct (Ascii.eqb a a0) eqn:E; simpl; rewrite E.
		apply IHs1. intro. subst. assert (a <> a0). intro. subst. contradiction.
		destruct (Ascii.eqb_neq a a0). rewrite (H2 H0) in E. inversion E. easy.
	- destruct s2. inversion H. intro. inversion H0.
	- intro. subst. simpl in H. rewrite Ascii.eqb_refl, String.eqb_refl in H. 
		inversion H.
Qed.

Lemma update_neq : forall (m : store) x y v,
	x <> y ->
	(x !-> v; m) y = m y.
Proof.
	intros. unfold update. destruct (eqb_neq x y). now rewrite String.eqb_sym, (H0 H).
Qed.

(* Compute fst (ispalindrome (update fresh_store "VP_STR" (VString "")) 5000) "VP_result". *)

Definition output_safe (f : store -> nat -> store * bool) 
		input expected :=
	forall loop_limit output, 
		(output, false) = f input loop_limit -> output "VP_result" = expected.

Theorem ispalindrome_small : forall s,
	(String.length s <= 1)%nat ->
	output_safe ispalindrome (update fresh_store "VP_STR" (VString s)) (VInteger 1).
Proof.
	intros s Small loop_limit output Terminates.
	assert (s = "" \/ (exists x, s = (String x ""))) as Size.
		destruct s. now left. right. exists a. destruct s. easy.
		simpl in Small. lia.
	destruct Size; [idtac|destruct H]; subst; destruct loop_limit; inversion Terminates;
		now rewrite update_neq, update_neq, update_eq.
Qed.

Ltac vpex_term term := 
	match term with [(?fst, ?snd) = 
			match ?m with (Some s) => ?s' | None => ?n' end] => idtac s
	end.

Ltac vpex :=
	match goal with [H: (?fst, ?snd) = 
		match ?m with (Some s) => ?s' | None => ?n' end |- _] =>
			let name := fresh "body" in
			remember m as name
	end || idtac "No match".

Theorem ispalindrome_ht : forall h t,
	pal t ->
	output_safe ispalindrome 
		(update fresh_store "VP_STR" (VString (String h t ++ (String h "")))) 
		(VInteger 1).
Proof.
	intros h t Pal loop_limit.
	revert Pal. induction loop_limit; intros Pal output Terminates.
	- inversion Terminates.
	- inversion Pal; subst. 
		-- clear IHloop_limit. unfold ispalindrome in Terminates.
			simpl in Terminates. vpex. rewrite get_int_eq in Heqbody.
			repeat unfold get_string at 5 in Heqbody;
				rewrite update_neq, update_neq, update_neq, update_eq in Heqbody; 
					try discriminate.
			repeat unfold string_subscript at 5 in Heqbody; simpl in Heqbody.
			unfold Z_noteqb in Heqbody. rewrite Z.eqb_refl in Heqbody.
				simpl in Heqbody. rewrite update_shadow in Heqbody.
			destruct loop_limit. subst. inversion Terminates.
			repeat rewrite get_int_eq in Heqbody.
			unfold get_int at 1 in Heqbody. rewrite update_neq, 
				update_eq in Heqbody; try discriminate.
			simpl in Heqbody. subst. inversion Terminates.
			rewrite update_neq, update_neq, update_eq; easy.
		-- apply (IHloop_limit Pal). clear Terminates IHloop_limit.
			induction (String x ""). (* last goal *) admit.

			
			

(* Theorem ispalindrome (update fresh_store "VP_STR" (VString "")) "VP_result" = VInteger 1. *)

Lemma neqb_refl : forall x,
	x !=? x = false.
Proof.
	intros. unfold Z_noteqb. now rewrite Z.eqb_refl.
Qed.

Hint Unfold get_int.
Hint Unfold get_string.

Definition palindrome_partial_correctness : 
	forall (s : string),
	pal s -> output_safe ispalindrome (update fresh_store "VP_STR" (VString s)) (VInteger 1).
Proof.
	(* intros. intros loop_limit output Terminates. induction loop_limit.
		inversion Terminates.
		unfold ispalindrome in Terminates. simpl in Terminates.
		unfold get_int in Terminates. rewrite 
			update_eq, update_neq, update_eq in Terminates; try discriminate.
		unfold get_string in Terminates at 1. rewrite 
			update_neq, update_eq in Terminates; try discriminate.
	destruct s. 
	- inversion Terminates. now rewrite update_neq, update_neq, update_eq.
	- destruct s. inversion Terminates. now rewrite update_neq, update_neq, update_eq.
		assert (1 <=?
		Z.of_nat
		  (String.length (String a (String a0 s))) /
		2 = true). clear H Terminates IHloop_limit. induction s. auto.
		 *)
	intros. intros loop_limit output Terminates. induction H; subst.
	- apply ispalindrome_small in Terminates; auto.
	- apply ispalindrome_small in Terminates; auto.
	- induction loop_limit; inversion Terminates. unfold ispalindrome in Terminates.
		simpl in *. unfold get_int in Terminates. 
		rewrite update_eq, update_neq, update_eq in Terminates.
		destruct (1 <=? _) in Terminates. vpex_term Terminates.
		

		inversion Terminates. rewrite update_neq, update_neq, update_eq.
			auto. all: discriminate.

	