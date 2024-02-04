(** logging.ml - Custom logging and error messages *)

(** Represents the severity of a log statement *)
type log_type =
  | Log_None
  | Log_Debug
  | Log_Info
  | Log_Cmd
  | Log_Warning
  | Log_Error
  | Log_Critical

let _GLOBAL_LOG_LEVEL = ref Log_Info

(** Follows the order in the type definition, \[0:5\]*)
let int_of_log = function
  | Log_Debug ->
      1
  | Log_Info | Log_Cmd ->
      2
  | Log_Warning ->
      3
  | Log_Error ->
      4
  | Log_Critical ->
      5
  | Log_None ->
      0

let range_of_logs =
  "["
  ^ string_of_int (int_of_log Log_None)
  ^ "-"
  ^ string_of_int (int_of_log Log_Critical)
  ^ "]"

let log_of_int = function
  | 1 ->
      Log_Debug
  | 2 ->
      Log_Info
  | 3 ->
      Log_Warning
  | 4 ->
      Log_Error
  | 5 ->
      Log_Critical
  | 0 ->
      Log_None
  | n ->
      failwith
        ( "Unrecognized log level " ^ string_of_int n ^ ", range is "
        ^ range_of_logs )

(** For exits, their appropriate return code and the message type *)
type return_code = int * string

let rc_Ok = (0, "OK")

and rc_Error = (1, "ERROR")

and rc_ParseError = (2, "PARSE ERROR")

and rc_CompileError = (3, "FPC ERROR")

and rc_CoqError = (4, "COQ ERROR")

and rc_ConversionError = (5, "CONVERSION ERROR")

and rc_UnimplementedError = (6, "UNIMPLEMENTED")

(** ANSI encoding for bold text *)
let ansi_bold = "\x1b[1m"

(** ANSI encoding for red text *)
let ansi_red = "\x1b[38:5:196m"

(** ANSI encoding for orange text *)
let ansi_orange = "\x1b[38:5:208m"

(** ANSI encoding for yellow text *)
let ansi_yellow = "\x1b[38:5:178m"

(** ANSI encoding for plain text *)
let ansi_reset = "\x1b[0m"

(** ANSI encoding for bold red text *)
let error_red = ansi_bold ^ ansi_red

(** ANSI encoding for bold orange text *)
let error_orange = ansi_bold ^ ansi_orange

(** ANSI encoding for bold yellow text *)
let error_yellow = ansi_bold ^ ansi_yellow

(** Gets the string representation of a {!log_type}*)

let ansi_of_log = function
  | Log_Debug | Log_Info | Log_Cmd ->
      ansi_bold
  | Log_Warning ->
      ansi_yellow
  | Log_Error ->
      ansi_orange
  | Log_Critical ->
      ansi_red
  | Log_None ->
      ansi_reset

let string_of_log = function
  | Log_Debug ->
      "[DEBUG]"
  | Log_Info ->
      "[INFO]"
  | Log_Cmd ->
      "[CMD]"
  | Log_Warning ->
      "[WARNING]"
  | Log_Error ->
      "[ERROR]"
  | Log_Critical ->
      "[CRITICAL]"
  | Log_None ->
      "[NONE]"

let max_len = 8

(** A fatal log statement that immediately exits the program *)
let fatal rc message =
  Printf.fprintf stderr
    "%s[%s] - %s%s\n----------------------------------------\n" error_red
    (snd rc) ansi_reset message ;
  flush stderr ;
  exit (fst rc)

(** Prints log statements to stdout/stderr *)
let _log log_level message =
  if
    log_level = Log_None || int_of_log !_GLOBAL_LOG_LEVEL > int_of_log log_level
  then ()
  else
    let stream =
      if log_level = Log_Debug || log_level = Log_Info then stdout else stderr
    in
    Printf.fprintf stream "LOG:%s%*s%s - %s\n" (ansi_of_log log_level) max_len
      (string_of_log log_level) ansi_reset message ;
    flush stream

let exc log_level message = _log log_level message ; raise (Failure message)
