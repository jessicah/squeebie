
open Xml

let prefix = "!weather"

let weather location =
	let uri = "http://api.wunderground.com/auto/wui/geo/WXCurrentObXML/index.xml?query=" ^ (Curl.escape location) in
	let conn = Curl.init () in
	let buffer = Buffer.create 1000 in
	Curl.set_writefunction conn (fun data -> Buffer.add_string buffer data; String.length data);
	Curl.set_url conn uri;
	Curl.perform conn;
	Curl.cleanup conn;
	(* Buffer.contents buffer is the XML *)
	(*
		current_observation
			display_location
				full: Omaha, AR
			weather: haze
			temp_f: 28
			temp_c: -2
			relative_humidity: 80%
			wind_dir: SE
			wind_mph: 5
	*)
	let to_string xml = String.concat "" (map pcdata xml) in
	let xml = parse_string (Buffer.contents buffer) in
	let location, temp_c, temp_f, desc, humidity, wind_mph, wind_dir = ref "", ref "", ref "", ref "", ref "", ref "", ref "" in
	iter begin fun xml ->
		if tag xml = "display_location" then
			iter begin fun xml ->
				if tag xml = "full" then
					location := to_string xml;
			end xml;
		if tag xml = "weather" then
			desc := to_string xml;
		if tag xml = "temp_c" then
			temp_c := Printf.sprintf "%s°C" (to_string xml);
		if tag xml = "temp_f" then
			temp_f := Printf.sprintf "%s°F" (to_string xml);
		if tag xml = "relative_humidity" then
			humidity := to_string xml;
		if tag xml = "wind_dir" then
			wind_dir := to_string xml;
		if tag xml = "wind_mph" then
			wind_mph := to_string xml;
		end xml;
	let wind_kph = string_of_int (int_of_float (float_of_string !wind_mph *. 1.609344)) in
	if !desc = "" then
		Printf.sprintf
			"%s: %s / %s; Humidity: %s - Wind: %s at %skm/h (%s mph)"
			!location !temp_c !temp_f !humidity !wind_dir wind_kph !wind_mph
	else
		Printf.sprintf
			"%s: %s / %s, %s - Humidity: %s - Wind: %s at %skm/h (%s mph)"
			!location !temp_c !temp_f !desc !humidity !wind_dir wind_kph !wind_mph

let () = Hashtbl.replace Table.extensions prefix weather
