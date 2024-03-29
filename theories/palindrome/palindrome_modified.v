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

Definition loop_body VP_store loop_limit :=
	let bounds_op := Z.leb in
	let iter_op := Z.add 1 in
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
		let VP_store := update VP_store "VP_I" (VInteger ( 1 )) in
			loop_body VP_store loop_limit)
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

(* Definition rev (s : string) :=
	string_of_list_ascii (rev (list_ascii_of_string s)). *)

Fixpoint rev (s : string) :=
	match s with 
	| "" => ""
	| String h t => (rev t ++ (String h ""))
	end.

Lemma string_of_list_ascii_distr : forall l1 l2,
	string_of_list_ascii (l1 ++ l2) = 
		string_of_list_ascii l1 ++ string_of_list_ascii l2.
Proof.
	induction l1; intros; auto.
	simpl in *. now rewrite IHl1.
Qed.

Lemma rev_String : forall a s,
	rev (String a s) = rev s ++ (String a EmptyString).
Proof.
	intros. generalize dependent a.
	induction s; simpl in *; intros ;reflexivity.
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
  pal (s ++ (rev s)).
Proof.
    induction s; simpl.
    constructor.
	replace (String a (s ++ rev s ++ String a "")) with 
		(String a (s ++ rev s) ++ String a ""). now constructor.
	now rewrite String_app_assoc, <- app_assoc, <- String_app_assoc.
Qed.

Lemma app_empty_r : forall s,
	s ++ "" = s.
Proof.
	induction s; simpl.
	reflexivity. now rewrite IHs.
Qed.

Lemma reverse_app_distr : forall s1 s2,
	rev (s1 ++ s2) = rev s2 ++ rev s1.
Proof.
	induction s1; intros; simpl in *.
	now rewrite app_empty_r.
	now rewrite app_assoc, <- IHs1.
Qed.

Theorem pal_rev : forall (s: string), 
    pal s -> s = rev s.
Proof.
    intros. induction H; simpl in *; try reflexivity.
    now rewrite reverse_app_distr, <- IHpal.
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
    (String.length s <= n)%nat -> s = rev s -> pal s.
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
			rewrite reverse_app_distr in H0; simpl in *.
            inversion H0. apply pal_ht.
            apply IHn. apply length_app_le in H.
            now destruct H.
            now apply app_single_end in H3.
Qed.

Theorem palindrome_converse: forall s,
    s = rev s -> pal s.
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

(* Theorem loop_body_one_iteration : forall loop_limit (s : store) h t,
	loop_body 
		("VP_STR" !-> (VString ((String h t) ++ (String h "")));
		 "VP_LEN" !-> (VInteger (Z.of_nat (String.length ((String h t) ++ (String h "")))));
		 "VP_I" !-> VInteger 0; s) loop_limit =
	loop_body 
		("VP_STR" !-> (VString ((String h t) ++ (String h "")));
		 "VP_LEN" !-> (VInteger (Z.of_nat (String.length ((String h t) ++ (String h "")))));
		 "VP_I" !-> (VInteger 1); s) loop_limit.
Proof.
	induction loop_limit; intros; simpl in *.
	- now unfold loop_body.
	- unfold loop_body; simpl. repeat rewrite get_string_eq.
		unfold get_int. rewrite update_neq, update_neq, update_eq, update_neq, update_eq,
			update_neq, update_neq, update_eq, update_neq, update_eq;
			try discriminate.
		destruct t; simpl. 
		-- repeat unfold string_subscript. simpl.
			replace (Z.of_nat (nat_of_ascii h) !=? -1) with true. simpl.
			replace (Z.of_nat (nat_of_ascii h) !=? Z.of_nat (nat_of_ascii h)) with false. simpl.
			rewrite update_permute, (update_permute _ _ _ "VP_I" "VP_STR"),
				(update_permute _ _ _ "VP_I" "VP_LEN"), update_shadow,
				(update_permute _ (VInteger 2) _ "VP_I"), (update_permute _ (VInteger 2) _ "VP_I" "VP_LEN"),
				update_shadow.
			reflexivity. *)

Lemma pal_String : forall h t,
	t <> "" ->
	pal (String h t) -> exists t', (String h t) = (String h t') ++ (String h "").
Proof.
	intros. remember (String h t). induction H0; inversion Heqs; subst.
	- contradiction.
	- now exists t0.
Qed.

Theorem ispalindrome_ht' : forall h t,
	pal t ->
	output_safe ispalindrome 
		(update fresh_store "VP_STR" (VString (String h t ++ (String h "")))) 
		(VInteger 1).
Proof.
	intros. intros loop_limit output. unfold ispalindrome. simpl.
	revert t output H h. induction loop_limit; intros.
	- simpl in H0. inversion H0.
	- unfold loop_body in H0. simpl in H0. unfold get_int in H0.
		rewrite update_eq, update_neq, update_eq in H0; try discriminate.
		unfold get_string in H0. rewrite 
			update_neq, update_neq, update_neq, update_eq in H0; try discriminate.
		destruct t; simpl in H0.
		-- unfold string_subscript in H0; simpl in H0.
			replace (Z.of_nat (nat_of_ascii h) !=? Z.of_nat (nat_of_ascii h)) with false in H0.
			rewrite update_eq, update_shadow in H0. destruct loop_limit; inversion H0.
			now rewrite update_neq, update_neq, update_eq. admit.
		-- pose (pal_String a t).
Admitted.

(* Theorem ispalindrome_ht' : forall h t,
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
			simpl in Terminates. vpex. unfold loop_body in Heqbody. 
			rewrite get_int_eq in Heqbody.
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
			(* Issue with this goal is that the IH talks about
				passing the inductive form of the string into the whole function,
				but I need something talking about the __fixpoint__ inside the 
				function alone... Seems like a loop invariant to me
			*) *)

			
			

(* Theorem ispalindrome (update fresh_store "VP_STR" (VString "")) "VP_result" = VInteger 1. *)

Lemma neqb_refl : forall x,
	x !=? x = false.
Proof.
	intros. unfold Z_noteqb. now rewrite Z.eqb_refl.
Qed.

Hint Unfold get_int.
Hint Unfold get_string.

Fixpoint remove_first_n_option (s : string) (n : nat) : option string :=
	match n with 
	| O => Some s
	| S n' => match s with "" => None | (String h t) => remove_first_n_option t n' end
	end.

Definition remove_last_n_option (s : string) (n : nat) : option string :=
	match remove_first_n_option (rev s) n with 
	| None => None
	| Some s' => Some (rev s')
	end.

Fixpoint remove_first_n (s : string) (n : nat) : string :=
	match n with 
	| O => s
	| S n' => match s with "" => "" | (String h t) => remove_first_n t n' end
	end.

Definition remove_last_n (s : string) (n : nat) : string :=
	rev (remove_first_n (rev s) n).

Definition split_option (s : string) : string * string :=
	let l := (String.length s / 2)%nat in 
	match (remove_last_n_option s l, remove_first_n_option s l) with 
	| (Some s1, Some s2) => (s1, s2)
	| _ => ("", "")
	end.

Definition split (s : string) : string * string :=
	let l := (String.length s / 2)%nat in 
	(remove_last_n s l, remove_first_n s (if even (String.length s) then l else l + 1)).

Definition remove_center_n_option (s : string) (n : nat) : option string :=
	let (s1, s2) := split s in 
	let n' := (n / 2)%nat in 
	match (remove_last_n_option s1 n'), (remove_first_n_option s2 n') with 
	| Some s1', Some s2' => Some (s1' ++ s2')
	| _, _ => None
	end.

Definition remove_center_n (s : string) (n : nat) : string :=
	let (s1, s2) := split s in 
	let n' := (n / 2)%nat in 
	remove_last_n s1 n' ++ remove_first_n s2 n'.

(* H: assert that if you remove everything from (string s) 
	except first and last 0 characters,
   then you get a palindrome (equals its rev) *)

(* revert H. 
replace s with its center (2 * 0) chars removed
generalize 0 (at _ ?) as i. 
Induct on loop_limit.
	Gets IH - if you've done everything up to i, 
	you now have up to i + 1 is a palindrome *)

Lemma app_empty : forall s1 s2,
	s1 ++ s2 = "" -> s1 = "" /\ s2 = "".
Proof.
	induction s1; intros; simpl in *.
	now split. inversion H.
Qed.

Lemma remove_first_zero : forall s,
	remove_first_n s 0 = s.
Proof. destruct s; reflexivity. Qed.

Lemma app_unfold : forall a s1 s2 s,
	s1 ++ s2 = String a s -> 
		(s1 <> "" /\ exists s1', (String a s1') ++ s2 = String a s) \/ 
		(s1 = "" /\ s2 = String a s).
Proof.
	induction s1; intros; simpl in *.
	- right. now split.
	- left. inversion H; subst. split. intro. inversion H0.
		now exists s1. 
Qed.

Lemma app_string_first_matches : forall a s1 s2 s3,
	(String a s1) ++ s2 = String a s3 ->
	s1 ++ s2 = s3.
Proof.
	induction s1; intros; simpl in *. now inversion H.
	now inversion H; subst.
Qed.

Lemma Strings_eq_tail : forall a s1 s2,
	s1 = s2 -> String a s1 = String a s2.
Proof. intros. now subst. Qed.

Lemma reverse_involutive : forall s,
	rev (rev s) = s.
Proof.
	induction s; simpl. reflexivity.
	rewrite reverse_app_distr, IHs. reflexivity.
Qed.

Lemma remove_last_zero : forall s,
	remove_last_n s 0 = s.
Proof.
	induction s; unfold remove_last_n; simpl.
	reflexivity. rewrite remove_first_zero.
	rewrite reverse_app_distr, reverse_involutive. reflexivity.
Qed.

Lemma split_join : forall s s1 s2, 
	split s = (s1, s2) ->
	s1 ++ s2 = s.
Admitted.

Lemma remove_center_zero : forall s,
	remove_center_n s 0 = s.
Proof.
	induction s. reflexivity. unfold remove_center_n.
	simpl (0 / 2)%nat. destruct (split (String a s)) eqn:E.
	now rewrite remove_last_zero, remove_first_zero, (split_join _ _ _ E).
Qed.

Definition palindrome_partial_correctness : 
	forall (s : string),
	(* pal s ->  *)
	s = rev s ->
	output_safe ispalindrome (update fresh_store "VP_STR" (VString s)) (VInteger 1).
Proof.
	intros s Pal loop_limit output Terminates.
	assert (H: remove_last_n (remove_first_n s 0) 0 = rev (remove_last_n (remove_first_n s 0) 0)).
		now rewrite remove_last_zero, remove_first_zero.
	revert H. replace s with (remove_center_n s (2 * 0)) in * by
		now simpl (2 * 0)%nat; rewrite remove_center_zero.
	unfold ispalindrome in Terminates. simpl in Terminates.
	revert s output Pal Terminates.
	generalize O at 2 4 5 6 7 8 10 11 12 14 15 16 as i.
	induction loop_limit; intros.
	- inversion Terminates.
	- apply IHloop_limit with i s; try assumption. unfold loop_body; simpl.
	
	unfold loop_body in Terminates; simpl in Terminates.
		unfold get_int in Terminates. rewrite update_eq, 
			update_neq, update_eq in Terminates; try discriminate.
		unfold get_string in Terminates. rewrite update_neq, update_eq,
			update_neq, update_neq, update_neq, update_eq in Terminates; try discriminate.
		

	
	
	
	replace s with (string_of_list_ascii (list_ascii_of_string s)) in *.
	unfold ispalindrome in Terminates. simpl in Terminates. vpex.
	assert 
	revert loop_limit H output Terminates. induction (list_ascii_of_string s); intros.
	simpl in *. admit.
	simpl in *. unfold ispalindrome in Terminates.


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

	