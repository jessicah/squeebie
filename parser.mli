type token =
  | EOL
  | STRING of (string)
  | COMMAND of (Types.command)

val args :
  (Lexing.lexbuf  -> token) -> Lexing.lexbuf -> string option * Types.command * string list
