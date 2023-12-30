
val negb : bool -> bool

val fst : ('a1 * 'a2) -> 'a1

val snd : ('a1 * 'a2) -> 'a2



module Pos :
 sig
  val succ : int -> int

  val add : int -> int -> int

  val add_carry : int -> int -> int

  val pred_double : int -> int
 end

val fold_left :
  ('a1 -> 'a2 -> 'a1) -> 'a2 list -> 'a1 -> 'a1

module Z :
 sig
  val double : int -> int

  val succ_double : int -> int

  val pred_double : int -> int

  val pos_sub : int -> int -> int

  val add : int -> int -> int
 end

val string_dec : char list -> char list -> bool

type id_type = char list

type value =
| Null
| Integer of int
| String of char list

type store = id_type list * (id_type -> value)

val ids : store -> id_type list

val in_ids : store -> id_type -> bool

val all_in_ids : store -> id_type list -> bool

val get : store -> id_type -> value

val get_int : store -> id_type -> int

val update :
  store -> id_type -> value -> id_type
  list * (char list -> value)



val main : store -> store
