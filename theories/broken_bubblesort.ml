
(** val negb : bool -> bool **)

let negb = function
| true -> false
| false -> true

type nat =
| O
| S of nat

(** val fst : ('a1 * 'a2) -> 'a1 **)

let fst = function
| (x, _) -> x

(** val snd : ('a1 * 'a2) -> 'a2 **)

let snd = function
| (_, y) -> y

type comparison =
| Eq
| Lt
| Gt

module Coq__1 = struct
 (** val add : nat -> nat -> nat **)
 let rec add n m =
   match n with
   | O -> m
   | S p -> S (add p m)
end
include Coq__1

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
        (fun q -> (fun p->1+2*p) (add_carry p q))
        (fun q -> (fun p->2*p) (add_carry p q))
        (fun _ -> (fun p->1+2*p) (succ p))
        y)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
        (fun q -> (fun p->2*p) (add_carry p q))
        (fun q -> (fun p->1+2*p) (add p q))
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
      (fun p -> (fun p->1+2*p) ((fun p->2*p) p))
      (fun p -> (fun p->1+2*p) (pred_double p))
      (fun _ -> 1)
      x

  (** val compare_cont : comparison -> int -> int -> comparison **)

  let rec compare_cont = fun c x y -> if x=y then c else if x<y then Lt else Gt

  (** val compare : int -> int -> comparison **)

  let compare = fun x y -> if x=y then Eq else if x<y then Lt else Gt

  (** val iter_op : ('a1 -> 'a1 -> 'a1) -> int -> 'a1 -> 'a1 **)

  let rec iter_op op p a =
    (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
      (fun p0 -> op a (iter_op op p0 (op a a)))
      (fun p0 -> iter_op op p0 (op a a))
      (fun _ -> a)
      p

  (** val to_nat : int -> nat **)

  let to_nat x =
    iter_op Coq__1.add x (S O)

  (** val of_succ_nat : nat -> int **)

  let rec of_succ_nat = function
  | O -> 1
  | S x -> succ (of_succ_nat x)
 end

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
        (fun q -> succ_double (pos_sub p q))
        (fun _ -> ((fun p->2*p) p))
        y)
      (fun p ->
      (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
        (fun q -> pred_double (pos_sub p q))
        (fun q -> double (pos_sub p q))
        (fun _ -> (Pos.pred_double p))
        y)
      (fun _ ->
      (fun f2p1 f2p f1 p ->
  if p<=1 then f1 () else if p mod 2 = 0 then f2p (p/2) else f2p1 (p/2))
        (fun q -> (~-) ((fun p->2*p) q))
        (fun q -> (~-) (Pos.pred_double q))
        (fun _ -> 0)
        y)
      x

  (** val add : int -> int -> int **)

  let add = (+)

  (** val opp : int -> int **)

  let opp = (~-)

  (** val sub : int -> int -> int **)

  let sub = (-)

  (** val compare : int -> int -> comparison **)

  let compare = fun x y -> if x=y then Eq else if x<y then Lt else Gt

  (** val leb : int -> int -> bool **)

  let leb x y =
    match compare x y with
    | Gt -> false
    | _ -> true

  (** val ltb : int -> int -> bool **)

  let ltb x y =
    match compare x y with
    | Lt -> true
    | _ -> false

  (** val geb : int -> int -> bool **)

  let geb x y =
    match compare x y with
    | Lt -> false
    | _ -> true

  (** val gtb : int -> int -> bool **)

  let gtb x y =
    match compare x y with
    | Gt -> true
    | _ -> false

  (** val to_nat : int -> nat **)

  let to_nat z0 =
    (fun f0 fp fn z -> if z=0 then f0 () else if z>0 then fp z else fn (-z))
      (fun _ -> O)
      (fun p -> Pos.to_nat p)
      (fun _ -> O)
      z0

  (** val of_nat : nat -> int **)

  let of_nat = function
  | O -> 0
  | S n0 -> (Pos.of_succ_nat n0)
 end

(** val string_dec : char list -> char list -> bool **)

let rec string_dec s x =
  match s with
  | [] -> (match x with
           | [] -> true
           | _::_ -> false)
  | a::s0 ->
    (match x with
     | [] -> false
     | a0::s1 -> if (=) a a0 then string_dec s0 s1 else false)

(** val eqb : char list -> char list -> bool **)

let rec eqb s1 s2 =
  match s1 with
  | [] -> (match s2 with
           | [] -> true
           | _::_ -> false)
  | c1::s1' ->
    (match s2 with
     | [] -> false
     | c2::s2' -> if (=) c1 c2 then eqb s1' s2' else false)

type 'a t =
| Nil
| Cons of 'a * nat * 'a t

type id_type = char list

type 'a vector = 'a t

type value =
| VNull
| VInteger of int
| VBool of bool
| VString of char list
| VArray of nat * int vector

type store = id_type list * (id_type -> value)

(** val ids : store -> id_type list **)

let ids =
  fst

(** val in_ids : store -> id_type -> bool **)

let in_ids vOLPIC_store s =
  let rec f = function
  | [] -> false
  | h :: t0 -> if string_dec h s then true else f t0
  in f (ids vOLPIC_store)

(** val sf_get : store -> id_type -> value **)

let sf_get =
  snd

(** val get_int : store -> id_type -> int **)

let get_int vOLPIC_store s =
  match sf_get vOLPIC_store s with
  | VInteger n -> n
  | _ -> 0

(** val get_array : store -> id_type -> int vector **)

let get_array vOLPIC_store s =
  let v = sf_get vOLPIC_store s in
  (match v with
   | VArray (_, v0) -> v0
   | _ -> Nil)

(** val subscript : nat -> 'a1 vector -> nat -> 'a1 -> 'a1 **)

let rec subscript _ vec n default =
  match n with
  | O -> (match vec with
          | Nil -> default
          | Cons (h, _, _) -> h)
  | S n' ->
    (match vec with
     | Nil -> default
     | Cons (_, n0, t0) -> subscript n0 t0 n' default)

(** val update : store -> id_type -> value -> store **)

let update vOLPIC_store s v =
  ((if in_ids vOLPIC_store s
    then fst vOLPIC_store
    else s :: (fst vOLPIC_store)), (fun x ->
    if eqb x s then v else snd vOLPIC_store x))

(** val fpc_dynarray_high : nat -> store -> 'a1 vector -> store **)

let fpc_dynarray_high n s _ =
  update s ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[])))))))))
    (VInteger (Z.sub (Z.of_nat n) 1))

(** val bubble_sort : store -> nat -> int vector -> store **)

let bubble_sort vP_store arr_len vec =
  let vP_poison = false in
  let vP_store0 =
    update vP_store
      ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[])))))))))
      (VArray (arr_len, vec))
  in
  if negb vP_poison
  then (match let going_up =
                Z.ltb
                  (Z.sub
                    (get_int
                      (fpc_dynarray_high arr_len vP_store0
                        (get_array vP_store0
                          ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[])))))))))))
                      ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))))
                    1) 0
              in
              let bounds_op = if going_up then Z.leb else Z.geb in
              let vP_store1 =
                update vP_store0 ('V'::('P'::('_'::('I'::[])))) (VInteger
                  (Z.sub
                    (get_int
                      (fpc_dynarray_high arr_len vP_store0
                        (get_array vP_store0
                          ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[])))))))))))
                      ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))))
                    1))
              in
              let rec loop vP_depth vP_broken vP_store2 =
                match vP_depth with
                | O -> None
                | S n' ->
                  if bounds_op
                       (get_int vP_store2 ('V'::('P'::('_'::('I'::[]))))) 0
                  then let vP_store3 =
                         let going_up0 =
                           Z.ltb 0
                             (get_int vP_store2
                               ('V'::('P'::('_'::('I'::[])))))
                         in
                         let bounds_op0 = if going_up0 then Z.leb else Z.geb
                         in
                         let iter_op0 = if going_up0 then Z.add 1 else Z.sub 1
                         in
                         let vP_store3 =
                           update vP_store2 ('V'::('P'::('_'::('J'::[]))))
                             (VInteger 0)
                         in
                         (match let rec loop0 vP_depth0 vP_broken0 vP_store4 =
                                  match vP_depth0 with
                                  | O -> None
                                  | S n'0 ->
                                    if bounds_op0
                                         (get_int vP_store4
                                           ('V'::('P'::('_'::('J'::[])))))
                                         (get_int vP_store4
                                           ('V'::('P'::('_'::('I'::[])))))
                                    then let vP_store5 =
                                           let vP_store5 =
                                             if Z.gtb
                                                  (subscript
                                                    (match sf_get vP_store4
                                                             ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))) with
                                                     | VArray (n, _) -> n
                                                     | _ -> O)
                                                    (get_array vP_store4
                                                      ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))))
                                                    (Z.to_nat
                                                      (get_int vP_store4
                                                        ('V'::('P'::('_'::('J'::[]))))))
                                                    0)
                                                  (subscript
                                                    (match sf_get vP_store4
                                                             ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))) with
                                                     | VArray (n, _) -> n
                                                     | _ -> O)
                                                    (get_array vP_store4
                                                      ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))))
                                                    (Z.to_nat
                                                      (Z.add
                                                        (get_int vP_store4
                                                          ('V'::('P'::('_'::('J'::[])))))
                                                        1)) 0)
                                             then let vP_store5 =
                                                    update vP_store4
                                                      ('V'::('P'::('_'::('T'::('E'::('M'::('P'::[])))))))
                                                      (VInteger
                                                      (subscript
                                                        (match sf_get
                                                                 vP_store4
                                                                 ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))) with
                                                         | VArray (n, _) -> n
                                                         | _ -> O)
                                                        (get_array vP_store4
                                                          ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))))
                                                        (Z.to_nat
                                                          (get_int vP_store4
                                                            ('V'::('P'::('_'::('J'::[]))))))
                                                        0))
                                                  in
                                                  let vP_store6 =
                                                    update vP_store5
                                                      ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[])))))))))
                                                      (VInteger
                                                      (subscript
                                                        (match sf_get
                                                                 vP_store5
                                                                 ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))) with
                                                         | VArray (n, _) -> n
                                                         | _ -> O)
                                                        (get_array vP_store5
                                                          ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[]))))))))))
                                                        (Z.to_nat
                                                          (Z.add
                                                            (get_int
                                                              vP_store5
                                                              ('V'::('P'::('_'::('J'::[])))))
                                                            1)) 0))
                                                  in
                                                  update vP_store6
                                                    ('V'::('P'::('_'::('r'::('e'::('s'::('u'::('l'::('t'::[])))))))))
                                                    (VInteger
                                                    (get_int vP_store6
                                                      ('V'::('P'::('_'::('T'::('E'::('M'::('P'::[])))))))))
                                             else vP_store4
                                           in
                                           update vP_store5
                                             ('V'::('P'::('_'::('J'::[]))))
                                             (VInteger
                                             (iter_op0
                                               (get_int vP_store5
                                                 ('V'::('P'::('_'::('J'::[])))))))
                                         in
                                         loop0 n'0 vP_broken0 vP_store5
                                    else Some vP_store4
                                in loop0 (S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( O))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) false vP_store3 with
                          | Some vP_store' ->
                            update vP_store' ('V'::('P'::('_'::('I'::[]))))
                              (VInteger
                              (iter_op0
                                (get_int vP_store'
                                  ('V'::('P'::('_'::('I'::[])))))))
                          | None ->
                            update vP_store3 ('V'::('P'::('_'::('I'::[]))))
                              (VInteger
                              (iter_op0
                                (get_int vP_store3
                                  ('V'::('P'::('_'::('I'::[]))))))))
                       in
                       loop n' vP_broken vP_store3
                  else Some vP_store2
              in loop (S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( S( O))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) false
                   vP_store1 with
        | Some vP_store' -> vP_store'
        | None -> vP_store0)
  else vP_store0

let x = Cons (3, S (S O), Cons (2, S O, Cons (1, O, Nil)))

let () = let _ = snd (bubble_sort ([], fun _ -> VNull) (S (S O)) x)  in ()
