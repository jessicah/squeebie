EXTS = $(subst ml,cmo, $(wildcard exts/*.ml))

all: squeebie $(EXTS)

$(EXTS): squeebie
	ocamlfind ocamlc -package unix,extlib,dynlink,xml-light,curl,json-wheel -c $(subst cmo,ml,$@)

squeebie: types.mli parser.mli parser.ml lexer.ml table.ml squeebie.ml
	ocamlfind ocamlc -package unix,extlib,dynlink,xml-light,curl,json-wheel -linkpkg -linkall -o $@ $+

parser.ml: parser.mly
	ocamlyacc $<

lexer.ml: lexer.mll
	ocamllex $<

clean:
	rm -f *.cm[io] parser.ml lexer.ml $(EXTS)
