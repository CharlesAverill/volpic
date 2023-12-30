
(** val negb : bool -> bool **)

let negb = function
| true -> false
| false -> true

(** val fst : ('a1 * 'a2) -> 'a1 **)

let fst = function
| (x, _) -> x

(** val snd : ('a1 * 'a2) -> 'a2 **)

let snd = function
| (_, y) -> y



module Pos =
 struct
  (** val succ : int -> int **)

  let rec succ = Pervasives.succ

  (** val add : int -> int -> int **)

  let rec add = (+)

  (** val add_carry : int -> int -> int **)

  and add_carry x y =
    (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
        (fun q -> (fun p->1+2*p)
        (add_carry p q))
        (fun q -> (fun p->2*p)
        (add_carry p q))
        (fun _ -> (fun p->1+2*p) (succ p))
        y)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
        (fun q -> (fun p->2*p)
        (add_carry p q))
        (fun q -> (fun p->1+2*p)
        (add p q))
        (fun _ -> (fun p->2*p) (succ p))
        y)
      (fun _ ->
      (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
        (fun q -> (fun p->1+2*p) (succ q))
        (fun q -> (fun p->2*p) (succ q))
        (fun _ -> (fun p->1+2*p) 1)
        y)
      x

  (** val pred_double : int -> int **)

  let rec pred_double x =
    (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
      (fun p -> (fun p->1+2*p) ((fun p->2*p)
      p))
      (fun p -> (fun p->1+2*p)
      (pred_double p))
      (fun _ -> 1)
      x
 end

(** val fold_left :
    ('a1 -> 'a2 -> 'a1) -> 'a2 list -> 'a1 -> 'a1 **)

let rec fold_left f l a0 =
  match l with
  | [] -> a0
  | b :: t -> fold_left f t (f a0 b)

module Z =
 struct
  (** val double : int -> int **)

  let double x =
    (fun f0 fp fn z -> if z=0 then f0 () else if z>0 then fp z else fn (-z))
      (fun _ -> 0)
      (fun p -> ((fun p->2*p) p))
      (fun p -> (~-) ((fun p->2*p) p))
      x

  (** val succ_double : int -> int **)

  let succ_double x =
    (fun f0 fp fn z -> if z=0 then f0 () else if z>0 then fp z else fn (-z))
      (fun _ -> 1)
      (fun p -> ((fun p->1+2*p) p))
      (fun p -> (~-) (Pos.pred_double p))
      x

  (** val pred_double : int -> int **)

  let pred_double x =
    (fun f0 fp fn z -> if z=0 then f0 () else if z>0 then fp z else fn (-z))
      (fun _ -> (~-) 1)
      (fun p -> (Pos.pred_double p))
      (fun p -> (~-) ((fun p->1+2*p) p))
      x

  (** val pos_sub : int -> int -> int **)

  let rec pos_sub x y =
    (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
        (fun q -> double (pos_sub p q))
        (fun q ->
        succ_double (pos_sub p q))
        (fun _ -> ((fun p->2*p) p))
        y)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
        (fun q ->
        pred_double (pos_sub p q))
        (fun q -> double (pos_sub p q))
        (fun _ -> (Pos.pred_double p))
        y)
      (fun _ ->
      (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
        (fun q -> (~-) ((fun p->2*p) q))
        (fun q -> (~-)
        (Pos.pred_double q))
        (fun _ -> 0)
        y)
      x

  (** val add : int -> int -> int **)

  let add = (+)
 end

(** val string_dec :
    char list -> char list -> bool **)

let rec string_dec s x =
  match s with
  | [] -> (match x with
           | [] -> true
           | _::_ -> false)
  | a::s0 ->
    (match x with
     | [] -> false
     | a0::s1 ->
       if (=) a a0 then string_dec s0 s1 else false)

type id_type = char list

type value =
| Null
| Integer of int
| String of char list

type store = id_type list * (id_type -> value)

(** val ids : store -> id_type list **)

let ids =
  fst

(** val in_ids : store -> id_type -> bool **)

let in_ids vOLPIC_store s =
  let rec f = function
  | [] -> false
  | h :: t -> if string_dec h s then true else f t
  in f (ids vOLPIC_store)

(** val all_in_ids :
    store -> id_type list -> bool **)

let all_in_ids vOLPIC_store l =
  fold_left (fun acc item ->
    (&&) acc (in_ids vOLPIC_store item)) l true

(** val get : store -> id_type -> value **)

let get =
  snd

(** val get_int : store -> id_type -> int **)

let get_int vOLPIC_store s =
  match get vOLPIC_store s with
  | Integer n -> n
  | _ -> 0

(** val update :
    store -> id_type -> value -> id_type
    list * (char list -> value) **)

let update vOLPIC_store s v =
  ((if in_ids vOLPIC_store s
    then fst vOLPIC_store
    else s :: (fst vOLPIC_store)), (fun x ->
    if string_dec x s then v else get vOLPIC_store s))



(** val main : store -> store **)

let main vP_store =
  let vP_poison = false in
  if (&&) (negb vP_poison) (all_in_ids vP_store [])
  then let vP_store0 =
         update vP_store
           ('V'::('P'::('_'::('Y'::[])))) (Integer
           ((fun p->2*p) ((fun p->1+2*p) 1)))
       in
       if (&&) (negb vP_poison)
            (all_in_ids vP_store0
              (('V'::('P'::('_'::('Y'::[])))) :: []))
       then let vP_store1 =
              update vP_store0
                ('V'::('P'::('_'::('X'::[]))))
                (Integer
                (Z.add ((fun p->1+2*p)
                  ((fun p->2*p) 1))
                  (get_int vP_store0
                    ('V'::('P'::('_'::('Y'::[])))))))
            in
            if (&&) (negb vP_poison)
                 (all_in_ids vP_store1
                   (('V'::('P'::('_'::('X'::[])))) :: []))
            then let vP_store2 =
                   (fun s x _ -> print_int x; s)
                     vP_store1
                     (get_int vP_store1
                       ('V'::('P'::('_'::('X'::[])))))
                     0
                 in
                 (fun s -> print_endline String.empty; s)
                   vP_store2
            else vP_store1
       else let vP_poison0 = true in
            if (&&) (negb vP_poison0)
                 (all_in_ids vP_store0
                   (('V'::('P'::('_'::('X'::[])))) :: []))
            then let vP_store1 =
                   (fun s x _ -> print_int x; s)
                     vP_store0
                     (get_int vP_store0
                       ('V'::('P'::('_'::('X'::[])))))
                     0
                 in
                 (fun s -> print_endline String.empty; s)
                   vP_store1
            else vP_store0
  else let vP_poison0 = true in
       if (&&) (negb vP_poison0)
            (all_in_ids vP_store
              (('V'::('P'::('_'::('Y'::[])))) :: []))
       then let vP_store0 =
              update vP_store
                ('V'::('P'::('_'::('X'::[]))))
                (Integer
                (Z.add ((fun p->1+2*p)
                  ((fun p->2*p) 1))
                  (get_int vP_store
                    ('V'::('P'::('_'::('Y'::[])))))))
            in
            if (&&) (negb vP_poison0)
                 (all_in_ids vP_store0
                   (('V'::('P'::('_'::('X'::[])))) :: []))
            then let vP_store1 =
                   (fun s x _ -> print_int x; s)
                     vP_store0
                     (get_int vP_store0
                       ('V'::('P'::('_'::('X'::[])))))
                     0
                 in
                 (fun s -> print_endline String.empty; s)
                   vP_store1
            else vP_store0
       else let vP_poison1 = true in
            if (&&) (negb vP_poison1)
                 (all_in_ids vP_store
                   (('V'::('P'::('_'::('X'::[])))) :: []))
            then let vP_store0 =
                   (fun s x _ -> print_int x; s)
                     vP_store
                     (get_int vP_store
                       ('V'::('P'::('_'::('X'::[])))))
                     0
                 in
                 (fun s -> print_endline String.empty; s)
                   vP_store0
            else vP_store
let _ = main ([], fun _ -> Null)
