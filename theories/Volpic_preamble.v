Require Import String.
Require Import ZArith.
Require Import List.
Import ListNotations.
Open Scope Z.
Open Scope list_scope.

Declare Scope vp_scope.
Open Scope vp_scope.
Definition id_type := string.

Inductive value : Type :=
| VNull
| VInteger   (n : Z)
| VBool      (b : bool)
| VString    (s : string).

Definition store : Type := (list id_type * (id_type -> value)).

Definition fresh_store : store := (nil, fun _ => VNull).

Definition ids : store -> list id_type := fst.
Definition in_ids (VOLPIC_store : store) (s : id_type) :=
    (fix f l := match l with 
        | nil => false
        | h :: t => if string_dec h s then true else f t
        end) (ids VOLPIC_store).
Definition all_in_ids (VOLPIC_store : store) (l : list id_type) :=
    List.fold_left (
        fun acc item => 
            andb acc (in_ids VOLPIC_store item)
    ) l true.

Definition sf_get (VOLPIC_store : store) (s : id_type) := (snd VOLPIC_store) s.

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

Definition update (VOLPIC_store : store) (s : id_type) (v : value) :=
    (if in_ids VOLPIC_store s then (fst VOLPIC_store) else s :: (fst VOLPIC_store), 
    fun x => if String.eqb x s then v else (snd VOLPIC_store x)).

Definition update_record (dest_store : store) (dest_prefix : id_type) (source_store : store) (source_prefix : id_type) :=
    let record_ids := List.filter (String.prefix source_prefix) (ids source_store) in
    List.fold_left (fun acc id => update acc (
        String.append dest_prefix (
            String.substring 
                (String.length source_prefix) 
                ((String.length id) - (String.length source_prefix)) 
                id
        )
    ) (sf_get source_store id)) record_ids dest_store.

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

(* Axiom fpc_write_text_uint : store -> Z -> Z -> store. *)
Definition fpc_write_text_uint (s : store) (_ _ : Z) := s.
Extract Inlined Constant fpc_write_text_uint => "(fun s x _ -> print_int x; s)".
(* Axiom fpc_writeln_end : store -> store. *)
Definition fpc_writeln_end (s : store) := s.
Extract Inlined Constant fpc_writeln_end => "(fun s -> print_endline String.empty; s)".
