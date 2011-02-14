
(*** squeebie ***)

Dynlink.init ();;
Dynlink.allow_unsafe_modules true;;

let load () =
	(* find all extensions in the 'exts' directory *)
	try
		let exts = Sys.readdir "exts" in
		Array.iter begin fun name ->
				try
					Dynlink.loadfile (Filename.concat "exts" name);
					Printf.printf "Loaded %s\n" name;
				with Dynlink.Error error -> print_endline (Dynlink.error_message error)
				| exn -> print_endline (Printexc.to_string exn)
			end exts
	with _ -> ()


let () =
	load ();
	Hashtbl.iter (fun prefix _ -> print_endline prefix) Table.extensions;
	Printf.printf "%d extensions registered\n" (Hashtbl.length Table.extensions)

(** configuration stuff **)

let hostname = ref ""
let port = ref 0
let use_ssl = ref false
let channel = ref ""
let nick = ref "squeebie"
let password = ref ""
let use_serverpass = ref false

let () =
	let spec = [
				"-hostname", Arg.Set_string hostname, " server to connect to";
				"-port", Arg.Set_int port, " port to connect to";
				"-ssl", Arg.Set use_ssl, " use ssl (optional)";
				"-channel", Arg.Set_string channel, " channel to join";
				"-nick", Arg.Set_string nick, " nickname of bot (optional)";
				"-password", Arg.Set_string password, " password for identifying to nickserv (optional)";
				"-serverpass", Arg.Set use_serverpass, " use server password to identify (optional)";
			]
	in
	try
		Arg.parse_argv Sys.argv (Arg.align spec) failwith "squeebie irc bot";
		(* some checks *)
		if !hostname = "" then failwith "hostname required";
		if !port = 0 then failwith "port required";
		if !channel = "" then failwith "channel required";
	with
		| Failure arg ->
			Arg.usage (Arg.align spec) ("unknown option: " ^ arg);
			exit 1
		| Arg.Help message ->
			print_endline message;
			exit 0
		| Arg.Bad error ->
			print_endline error;
			exit 2

(** connect to a server **)

open Unix

let connect () =
	print_endline "looking up server...";
	let sockaddr = ADDR_INET((gethostbyname !hostname).h_addr_list.(0), !port) in
	if !use_ssl then begin
		failwith "can't do SSL yet"
	end else begin
		print_endline "connecting to server...";
		open_connection sockaddr
	end

(** main loop **)

open Types
open ExtString

let printf args = Printf.printf (args ^^ "\r\n")

let main_loop () =
	let in_chan, out_chan = connect () in
	let writef args = Printf.fprintf out_chan (args ^^ "\r\n%!") in
	let clean user =
		try
			String.sub user 0 (String.index user '!')
		with Not_found -> user
	in
	(* irc initiation *)
	print_endline "connecting to IRC...";
	if !password <> "" then writef "PASS :%s %s" !nick !password;
	writef "NICK %s" !nick;
	writef "USER %s %s %s :%s" !nick (gethostname()) !hostname "squeebie! https://github.com/jessicah/squeebie";
	print_endline "waiting to join channel...";
	while true do
		let line = input_line in_chan in
		print_endline ("recv: " ^ line);
		match Parser.args Lexer.message (Lexing.from_string line) with
			| _, Num 001, _ ->
				(* ready to join channel *)
				print_endline "joining channel...";
				writef "JOIN %s" !channel
			| Some user, Cmd "PRIVMSG", _ :: msg :: []
				when String.starts_with msg "\001VERSION" ->
					(* CTCP version *)
					writef "NOTICE %s :\001VERSION squeebie! https://github.com/jessicah/squeebie" (clean user)
			| Some user, Cmd "PRIVMSG", target :: msg :: []
				when String.length msg > 0 && String.contains msg ' ' ->
					(* something to maybe process *)
					let prefix, rest = String.split msg " " in
					if Hashtbl.mem Table.extensions prefix then begin
						try
							let response = (Hashtbl.find Table.extensions prefix) rest in
							writef "PRIVMSG %s :%s" !channel response
						with _ -> ()
					end
			| None, Cmd "PING", data :: [] ->
					writef "PONG :%s" data
			| _ -> ()
	done

let () =
	while true do
		try
			main_loop ()
		with exn ->
			print_endline (Printexc.to_string exn);
	done
