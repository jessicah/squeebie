
{
open Lexing
open Parser
open Types
}

let letter = [^' ']
let digit  = ['0'-'9']

rule param = parse
  | ':'((letter|' ')* as s)    { STRING s }
  | (letter+) as s             { STRING s }
  | [' ']+                     { param lexbuf }
  | eof                        { EOL }
and command = parse
  | (digit digit digit) as num { COMMAND (Num (int_of_string num)) }
  | (letter+) as s             { COMMAND (Cmd s) }
and sender = parse
  | ((letter+) as s)[' ']+     { STRING s }
and message = parse
  | ':'                        { sender lexbuf }
  | [' ']+                     { param lexbuf }
  | ""                         { command lexbuf }
  | eof                        { EOL }
