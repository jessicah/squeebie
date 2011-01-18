EXTS = $(subst ml,cmo, $(wildcard exts/*.ml))

all: squeebie.byte $(EXTS)
	ln -fs _build/squeebie.byte squeebie.byte

$(EXTS): squeebie.byte
	ocamlbuild -no-hygiene $@
	cp -f _build/$@ $@

squeebie.byte: squeebie.ml
	ocamlbuild -no-hygiene -lflag -linkall squeebie.byte

clean:
	ocamlbuild -clean
	rm -rf exts/*.cmo

