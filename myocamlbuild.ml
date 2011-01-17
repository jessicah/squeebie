open Ocamlbuild_plugin
open Command
;;

ocaml_lib ~extern:true ~dir:"+extlib" ~tag_name:"use_extlib" "extLib";;
ocaml_lib ~extern:true ~dir:"+curl" "curl";;
ocaml_lib ~extern:true ~dir:"+xml-light" ~tag_name:"use_xml" "xml-light";;


