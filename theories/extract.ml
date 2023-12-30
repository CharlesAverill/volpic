
(** val string_of_char_list :
    char list -> char list **)

let string_of_char_list = fun cl -> (String.of_seq (List.to_seq cl))

(** val init_module : unit **)

let init_module =
  print_endline
    (string_of_char_list
      ('H'::('e'::('l'::('l'::('o'::(' '::('W'::('o'::('r'::('l'::('d'::('!'::[])))))))))))))
