Require Import String.
Require Import ZArith.
Require Import List.
Require Import FunctionalExtensionality.
Import ListNotations.
Open Scope Z.
Open Scope string_scope.
Open Scope list_scope.

Definition id_type := string.

Inductive value : Type :=
| VNull
| VInteger   (n : Z)
| VBool      (b : bool)
| VString    (s : string)
| VArray     (T : Set) (n : nat) (v : list T).

(* Definition store : Type := (list id_type * (id_type -> value)). *)
Definition store : Type := id_type -> value.

(* Definition fresh_store : store := (nil, fun _ => VNull). *)
Definition fresh_store : store := fun _ => VNull.

(* Definition ids : store -> list id_type := fst.
Definition in_ids (VOLPIC_store : store) (s : id_type) :=
    (fix f l := match l with 
        | nil => false
        | cons h t => if string_dec h s then true else f t
        end) (ids VOLPIC_store).
Definition all_in_ids (VOLPIC_store : store) (l : list id_type) :=
    List.fold_left (
        fun acc item => 
            andb acc (in_ids VOLPIC_store item)
    ) l true. *)

(* Definition sf_get (VOLPIC_store : store) (s : id_type) := (snd VOLPIC_store) s. *)
(* Definition sf_get (s : store) id := s id. *)

Definition get_int (VOLPIC_store : store) (s : id_type) :=
    match VOLPIC_store s with
    | VInteger n => n
    | _ => 0
    end.

Definition get_string (VOLPIC_store : store) (s : id_type) :=
    match VOLPIC_store s with
    | VString s => s
    | _ => EmptyString
    end.

Definition get_bool (VOLPIC_store : store) (s : id_type) :=
    match VOLPIC_store s with
    | VBool b => b
    | _ => false
    end.

(* TODO : UNDO WHEN FIX ARRAYS *)
(* Definition get_array (VOLPIC_store : store) (s : id_type) :
    vector (match sf_get VOLPIC_store s with 
     | VArray T n _ => T
     | _ => unit
     end) (match sf_get VOLPIC_store s with 
     | VArray T n _ => n
     | _ => 0
     end).
     destruct (sf_get VOLPIC_store s);
        try exact v;
        exact (Vector.nil unit).
Defined. *)

(* Definition get_array (VOLPIC_store : store) (s : id_type) :
    vector Z (match sf_get VOLPIC_store s with | VArray T n _ => n | _ => 0 end).
    destruct (sf_get VOLPIC_store s);
        try exact v;
        exact (Vector.nil Z).
Defined. *)

Definition get_array (VOLPIC_store : store) (s : id_type) :
    list (match VOLPIC_store s with VArray T _ _ => T | _ => Z end).
    destruct (VOLPIC_store s);
        try exact v;
        exact [].
Defined.

(* TODO : UNDO WHEN FIX ARRAYS *)
(* Definition constr_varray {T : Type} {n : nat} (vec : vector T n) :=
    VArray T n vec. *)
(* Definition constr_varray {n : nat} (vec : vector Z n) :=
    VArray Z n vec. *)

Fixpoint pad_vec {T : Type} (n : nat) (item : T) : list T :=
    match n with
    | O => []
    | S n' => item :: (pad_vec n' item)
    end.

Fixpoint array_take {T : Type} (n : nat) (vec : list T) : list T :=
    match n with
    | O => []
    | S n' => match vec with [] => [] | h :: t => h :: (array_take n' t) end
    end.

Fixpoint subscript_nat {T : Type} (vec : list T) (n : nat) : option T :=
	match n with
	| O => match vec with [] => None | h :: t => Some h end
	| S n' => match vec with [] => None | _ :: t => subscript_nat t n' end
	end.

Definition subscript {T : Type} (vec : list T) (n : Z) : option T :=
    subscript_nat vec (Z.to_nat n).

(* Definition update (VOLPIC_store : store) (s : id_type) (v : value) : store :=
    (if in_ids VOLPIC_store s then (fst VOLPIC_store) else cons s (fst VOLPIC_store), 
    fun x => if String.eqb x s then v else (snd VOLPIC_store x)). *)
Definition update (s : store) (x : id_type) (y : value) (id : id_type) : value :=
    if id =? x then y else s id.

Notation "'_' '!->' v" := (fresh_store v)
    (at level 100, right associativity) : volpic_notation.
Notation "x '!->' y ';' f" := (update f x y)
    (at level 100, y at next level, right associativity) : volpic_notation.

Open Scope volpic_notation.

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
	intros. unfold update. destruct (eqb_neq x y). now rewrite eqb_sym, (H1 H).
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
  pose proof (String.eqb_eq x x1). pose proof (String.eqb_eq x x2).
  destruct H0, H1. specialize (H0 E). specialize (H1 E'). subst. contradiction.
Qed.

Close Scope volpic_notation.

(* Definition update_record (dest_store : store) (dest_prefix : id_type) (source_store : store) (source_prefix : id_type) :=
    let record_ids := List.filter (String.prefix source_prefix) (ids source_store) in
    List.fold_left (fun acc id => update acc (
        String.append dest_prefix (
            String.substring 
                (String.length source_prefix) 
                ((String.length id) - (String.length source_prefix)) 
                id
        )
    ) (sf_get source_store id)) record_ids dest_store. *)

Definition multi_ands bl :=
    List.fold_left andb bl true.

Require Import Coq.extraction.Extraction.
Require Import ExtrOcamlBasic.
Require Import ExtrOcamlString.
Require Import ExtrOcamlZInt.

Axiom string_of_char_list : string -> string.
Extract Constant string_of_char_list => "fun cl -> (String.of_seq (List.to_seq cl))".

Axiom print_endline : string -> unit.
Extract Inlined Constant print_endline => "print_endline".

Axiom print_int : Z -> unit.
Extract Inlined Constant print_int => "print_int".

Definition fpc_write_text_uint (s : store) (_ _ : Z) := s.
Definition fpc_write_text_sint := fpc_write_text_uint.
Extract Inlined Constant fpc_write_text_uint => "(fun s x _ -> print_int x; s)".
Definition fpc_write_text_char (s : store) (_ _ : Z) := s.
Extract Inlined Constant fpc_write_text_char => "(fun s x _ -> print_char (char_of_int x); s)".
Definition fpc_write_end (s : store) := s.
Definition fpc_write_text_ansistr (s : store) (str : string) := s.
Extract Inlined Constant fpc_write_text_ansistr => "(fun s str -> print_string str; s)".
Definition IntToStr (s : store) (x : Z) := ""%string.
Extract Inlined Constant IntToStr => "(fun s x -> string_of_int x)".
Definition fpc_write_text_shortstr := fpc_write_text_ansistr.
Definition fpc_writeln_end (s : store) := s.
Definition printchar := fpc_write_text_char.
Extract Inlined Constant fpc_writeln_end => "(fun s -> print_endline String.empty; s)".

Definition fpc_dynarray_high {T: Type}
        (s : store) (v : list T) : store :=
    update s "VP_result" (VInteger ((Z.of_nat (List.length v)) - 1)).

Definition Z_noteqb (x y : Z) := negb (Z.eqb x y).
Infix "!=?" := Z_noteqb (at level 70, no associativity) : Z_scope.

Definition list_type {T : Type} (_ : list T) := T.

Definition set_length :
    forall (s : store) (id : string) (new_len : nat)
        (default : match s id with VArray T _ _ => T | _ => Z end),
    store.
Proof.
    intros.
        destruct (s id) eqn:E; 
            (* Filter out non-lists *)
            (assert (v = v) by reflexivity) || exact s.
        remember (length v) as old_len.
        destruct (old_len <? new_len)%nat.
        - (* true *)
            exact (update s id (VArray T new_len (
                v ++ (pad_vec (new_len - old_len) default)
            ))).
        - (* false *)
            exact (update s id (VArray T new_len (
                array_take new_len v
            ))).
Defined.
