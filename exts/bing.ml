
(* bing search *)

(*
{
	SearchResponse: {
		Version: 2.2
		Query: {
			SearchTerms: lmgtfy
			}
		Web: {
			Total: 210000
			Offset: 0
			Results: [
				{
					Title: Let me google that for you
					Description: For all those people...
					Url: http://lmgtfy.com
					DateTime: 2011-01-16T09:50:00Z
				}
				{
					...
				}
			]
		}
	}
}
*)
(* Object [SearchResponse (
	Object [Version; Query; Web (
		Object [Total; Offset; Results (Array [|
			Object [Title; Description; Url (String "http://lmgtfy.com")]; ...
		|]))])] *)

open Json_type

let apikey = "4D7951D82E23CAB5079FBF98593075F3B7AC4A88"

let prefix = ".b"

let parse_response obj =
	let tbl = Browse.make_table (Browse.objekt obj) in
	let resp_tbl = Browse.make_table (Browse.objekt (Browse.field tbl "SearchResponse")) in
	let web_tbl = Browse.make_table (Browse.objekt (Browse.field resp_tbl "Web")) in
	let results = Browse.list Browse.objekt (Browse.field web_tbl "Results") in
	(* the URL *)
	Browse.string (Browse.field (Browse.make_table (List.hd results)) "Url")

let search query =
	let uri = Printf.sprintf "http://api.bing.net/json.aspx?appid=%s&webcount=1&sources=web&query=%s" apikey (Curl.escape query) in
	let conn = Curl.init () in
	let buffer = Buffer.create 1000 in
	Curl.set_writefunction conn (fun data -> Buffer.add_string buffer data; String.length data);
	Curl.set_url conn uri;
	Curl.perform conn;
	Curl.cleanup conn;
	parse_response (Json_io.json_of_string (Buffer.contents buffer))

let () = Hashtbl.replace Table.extensions prefix search
