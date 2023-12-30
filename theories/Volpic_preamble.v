Require Import String.
Require Import ZArith.
Require Import List.
Import ListNotations.
Open Scope Z.
Open Scope list_scope.

Definition id_type := string.

Inductive value : Type :=
| Null
| Integer   (n : Z)
| String    (s : string).

Definition store : Type := (list id_type * (id_type -> value)).

Definition fresh_store : store := (nil, fun _ => Null).

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

Definition get (VOLPIC_store : store) (s : id_type) := (snd VOLPIC_store) s.

Definition get_int (VOLPIC_store : store) (s : id_type) :=
    match get VOLPIC_store s with
    | Integer n => n
    | _ => 0
    end.

Definition get_string (VOLPIC_store : store) (s : id_type) :=
    match get VOLPIC_store s with
    | String s => s
    | _ => EmptyString
    end.

Definition update (VOLPIC_store : store) (s : id_type) (v : value) :=
    (if in_ids VOLPIC_store s then (fst VOLPIC_store) else s :: (fst VOLPIC_store), 
    fun x => if string_dec x s then v else (get VOLPIC_store s)).

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

Axiom fpc_write_text_uint : store -> Z -> Z -> store.
Extract Inlined Constant fpc_write_text_uint => "(fun s x _ -> print_int x; s)".
Axiom fpc_writeln_end : store -> store.
Extract Inlined Constant fpc_writeln_end => "(fun s -> print_endline String.empty; s)".
