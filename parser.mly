
%token EOL
%token <string> STRING
%token <Types.command> COMMAND

%start args
%type <string option * Types.command * string list> args
%%

params:
  | STRING params { $1 :: $2 }
  | EOL { [] }

args:
  | STRING COMMAND params { (Some $1, $2, $3) }
  | COMMAND params { (None, $1, $2) }

