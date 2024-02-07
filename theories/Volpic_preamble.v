Require Import String.
Require Import ZArith.
Require Import Vector.
Require Import List.
Import VectorNotations.
Open Scope Z.
Open Scope string_scope.

Declare Scope vp_scope.
Open Scope vp_scope.
Definition id_type := string.

Definition vector := t.

Inductive value : Type :=
| VNull
| VInteger   (n : Z)
| VBool      (b : bool)
| VString    (s : string)
| VArray     (T : Type) (n : nat) (v : vector Z n).
(* | VArray     (T : Type) (n : nat) (v : vector T n). *)

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
Definition sf_get (s : store) id := s id.

Definition get_int (VOLPIC_store : store) (s : id_type) :=
    match sf_get VOLPIC_store s with
    | VInteger n => n
    | _ => 0
    end.

Definition get_string (VOLPIC_store : store) (s : id_type) :=
    match sf_get VOLPIC_store s with
    | VString s => s
    | _ => EmptyString
    end.

Definition get_bool (VOLPIC_store : store) (s : id_type) :=
    match sf_get VOLPIC_store s with
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

Definition get_array (VOLPIC_store : store) (s : id_type) :
    vector Z (match sf_get VOLPIC_store s with | VArray T n _ => n | _ => 0 end).
    destruct (sf_get VOLPIC_store s);
        try exact v;
        exact (Vector.nil Z).
Defined.

(* TODO : UNDO WHEN FIX ARRAYS *)
(* Definition constr_varray {T : Type} {n : nat} (vec : vector T n) :=
    VArray T n vec. *)
Definition constr_varray {n : nat} (vec : vector Z n) :=
    VArray Z n vec.

Definition array_type {T : Type} {n : nat} (vec : vector T n) := T.
Definition array_size {T : Type} {n : nat} (vec : vector T n) := n.

Fixpoint pad_vec {T : Type} (n : nat) (item : T) : vector T n :=
    match n with
    | O => []
    | S n' => item :: (pad_vec n' item)
    end.

Fixpoint int_array_take {x : nat} (n : nat) (vec : vector Z x) : vector Z n :=
    match n with
    | O => []
    | S n' => match vec with [] => pad_vec (S n') 0 | h :: t => h :: (int_array_take n' t) end
    end.

Fixpoint subscript {T : Type} {len : nat} (vec : vector T len) (n : nat) (default : T) :=
	match n with
	| O => match vec with [] => default | h :: t => h end
	| S n' => match vec with [] => default | _ :: t => subscript t n' default end
	end.

    Require Import Lia.
Compute replace_order [1;2;3] (ltac:(lia) : (1 < 3)%nat) 9.

Print store.

(* Definition update (VOLPIC_store : store) (s : id_type) (v : value) : store :=
    (if in_ids VOLPIC_store s then (fst VOLPIC_store) else cons s (fst VOLPIC_store), 
    fun x => if String.eqb x s then v else (snd VOLPIC_store x)). *)
Definition update (s : store) (x : id_type) (y : value) (id : id_type) : value :=
    if id =? x then y else s id.
Notation "f [ x := y ]" := (update f x y) (at level 50, left associativity, format "f '/' [ x  :=  y ]").


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

Close Scope vp_scope.

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
Extract Inlined Constant fpc_writeln_end => "(fun s -> print_endline String.empty; s)".

Definition fpc_dynarray_high {T: Type} {n: nat}
        (s : store) (v : vector T n) : store :=
    update s "VP_result" (VInteger ((Z.of_nat n) - 1)).

Definition Z_noteqb (x y : Z) := negb (Z.eqb x y).
Infix "!=?" := Z_noteqb (at level 70, no associativity) : Z_scope.

(* Definition setlength (s : store) (id : string) (new_len : nat) :=
    let old_vec := get_array s id in 
    let (T,old_len) := 
        ((* array_type old_vec *)Z, 
            array_size old_vec) in
    let new_vec :=
        if (old_len <? new_len)%nat then 
            append old_vec (pad_vec (new_len - old_len) 0)
        else
            int_array_take new_len old_vec in 
    update s id (VArray T new_len new_vec). *)
