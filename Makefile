#########################################################################
#                                                                       #
#                                 OCaml                                 #
#                                                                       #
#   Nicolas Pouillard, Berke Durak, projet Gallium, INRIA Rocquencourt  #
#                                                                       #
#   Copyright 2007 Institut National de Recherche en Informatique et    #
#   en Automatique.  All rights reserved.  This file is distributed     #
#  under the terms of the GNU Library General Public License, with      #
#  the special exception on linking described in file ../LICENSE.       #
#                                                                       #
#########################################################################

# see 'check-if-preinstalled' target
CHECK_IF_PREINSTALLED ?= true

# this configuration file is generated from configure.make
include Makefile.config

ifeq ($(OCAML_NATIVE_TOOLS), true)
OCAMLC    ?= ocamlc.opt
OCAMLOPT  ?= ocamlopt.opt
OCAMLDEP  ?= ocamldep.opt
OCAMLLEX  ?= ocamllex.opt
else
OCAMLC    ?= ocamlc
OCAMLOPT  ?= ocamlopt
OCAMLDEP  ?= ocamldep
OCAMLLEX  ?= ocamllex
endif

CP        ?= cp
COMPFLAGS ?= -w L -w R -w Z -I src -I +unix -safe-string -bin-annot -strict-sequence
LINKFLAGS ?= -I +unix -I src

PACK_CMO= $(addprefix src/,\
  const.cmo \
  loc.cmo \
  discard_printf.cmo \
  signatures.cmi \
  my_std.cmo \
  my_unix.cmo \
  tags.cmo \
  display.cmo \
  log.cmo \
  shell.cmo \
  bool.cmo \
  glob_ast.cmo \
  glob_lexer.cmo \
  glob.cmo \
  lexers.cmo \
  param_tags.cmo \
  command.cmo \
  ocamlbuild_config.cmo \
  ocamlbuild_where.cmo \
  slurp.cmo \
  options.cmo \
  pathname.cmo \
  configuration.cmo \
  flags.cmo \
  hygiene.cmo \
  digest_cache.cmo \
  resource.cmo \
  rule.cmo \
  solver.cmo \
  report.cmo \
  tools.cmo \
  fda.cmo \
  findlib.cmo \
  ocaml_arch.cmo \
  ocaml_utils.cmo \
  ocaml_dependencies.cmo \
  ocaml_compiler.cmo \
  ocaml_tools.cmo \
  ocaml_specific.cmo \
  rml_specific.cmo \
  exit_codes.cmo \
  plugin.cmo \
  hooks.cmo \
  main.cmo \
  )

EXTRA_CMO=$(addprefix src/,\
  ocamlbuild_plugin.cmo \
  ocamlbuild_executor.cmo \
  ocamlbuild_unix_plugin.cmo \
  )

PACK_CMX=$(PACK_CMO:.cmo=.cmx)
EXTRA_CMX=$(EXTRA_CMO:.cmo=.cmx)
EXTRA_CMI=$(EXTRA_CMO:.cmo=.cmi)

INSTALL_LIB=\
  src/rmlbuildlib.cma \
  src/ocamlbuild.cmo \
  src/rmlbuild_pack.cmi \
  $(EXTRA_CMO:.cmo=.cmi)

INSTALL_LIB_OPT=\
  src/rmlbuildlib.cmxa src/rmlbuildlib$(EXT_LIB) \
  src/ocamlbuild.cmx src/ocamlbuild$(EXT_OBJ) \
  src/rmlbuild_pack.cmx \
  $(EXTRA_CMO:.cmo=.cmx) $(EXTRA_CMO:.cmo=$(EXT_OBJ))

INSTALL_LIBDIR=$(DESTDIR)$(LIBDIR)
INSTALL_BINDIR=$(DESTDIR)$(BINDIR)
INSTALL_MANDIR=$(DESTDIR)$(MANDIR)

INSTALL_SIGNATURES=\
  src/signatures.mli \
  src/signatures.cmi \
  src/signatures.cmti

ifeq ($(OCAML_NATIVE), true)
all: byte native man
else
all: byte man
endif

byte: ocamlbuild.byte src/rmlbuildlib.cma
                 # ocamlbuildlight.byte ocamlbuildlightlib.cma
native: ocamlbuild.native src/rmlbuildlib.cmxa

allopt: all # compatibility alias

distclean:: clean

# The executables

ocamlbuild.byte: src/rmlbuild_pack.cmo $(EXTRA_CMO) src/ocamlbuild.cmo
	$(OCAMLC) $(LINKFLAGS) -o $@ unix.cma $^

ocamlbuildlight.byte: src/rmlbuild_pack.cmo src/ocamlbuildlight.cmo
	$(OCAMLC) $(LINKFLAGS) -o $@ $^

ocamlbuild.native: src/rmlbuild_pack.cmx $(EXTRA_CMX) src/ocamlbuild.cmx
	$(OCAMLOPT) $(LINKFLAGS) -o $@ unix.cmxa $^

# The libraries

src/rmlbuildlib.cma: src/rmlbuild_pack.cmo $(EXTRA_CMO)
	$(OCAMLC) -a -o $@ $^

src/rmlbuildlightlib.cma: src/rmlbuild_pack.cmo src/ocamlbuildlight.cmo
	$(OCAMLC) -a -o $@ $^

src/rmlbuildlib.cmxa: src/rmlbuild_pack.cmx $(EXTRA_CMX)
	$(OCAMLOPT) -a -o $@ $^

# The packs

# Build artifacts are first placed into tmp/ to avoid a race condition
# described in https://caml.inria.fr/mantis/view.php?id=4991.

src/rmlbuild_pack.cmo: $(PACK_CMO)
	mkdir -p tmp
	$(OCAMLC) -pack $^ -o tmp/rmlbuild_pack.cmo
	mv tmp/rmlbuild_pack.cmi src/rmlbuild_pack.cmi
	mv tmp/rmlbuild_pack.cmo src/rmlbuild_pack.cmo

src/rmlbuild_pack.cmi: src/rmlbuild_pack.cmo

src/rmlbuild_pack.cmx: $(PACK_CMX)
	mkdir -p tmp
	$(OCAMLOPT) -pack $^ -o tmp/rmlbuild_pack.cmx
	mv tmp/rmlbuild_pack.cmx src/rmlbuild_pack.cmx
	mv tmp/rmlbuild_pack$(EXT_OBJ) src/rmlbuild_pack$(EXT_OBJ)

# The lexers

src/lexers.ml: src/lexers.mll
	$(OCAMLLEX) src/lexers.mll
clean::
	rm -f src/lexers.ml
beforedepend:: src/lexers.ml

src/glob_lexer.ml: src/glob_lexer.mll
	$(OCAMLLEX) src/glob_lexer.mll
clean::
	rm -f src/glob_lexer.ml
beforedepend:: src/glob_lexer.ml

# The config file

configure:
	$(MAKE) -f configure.make all

# proxy rule for rebuilding configuration files directly from the main Makefile
Makefile.config src/ocamlbuild_config.ml:
	$(MAKE) -f configure.make $@

clean::
	$(MAKE) -f configure.make clean

distclean::
	$(MAKE) -f configure.make distclean

beforedepend:: src/ocamlbuild_config.ml

# man page

man: man/rmlbuild.1

man/rmlbuild.1: man/rmlbuild.header.1 man/rmlbuild.options.1 man/rmlbuild.footer.1
	cat $^ > man/rmlbuild.1

man/rmlbuild.options.1: man/options_man.byte
	./man/options_man.byte > man/rmlbuild.options.1

clean::
	rm -f man/rmlbuild.options.1

distclean::
	rm -f man/rmlbuild.1

man/options_man.byte: src/rmlbuild_pack.cmo
	$(OCAMLC) $^ -I src man/options_man.ml -o man/options_man.byte

clean::
	rm -f man/options_man.cm*
	rm -f man/options_man.byte
ifdef EXT_OBJ
	rm -f man/options_man$(EXT_OBJ)
endif

# Testing

test-%: testsuite/%.ml all
	cd testsuite && ocaml $(CURDIR)/$<

test: test-internal test-findlibonly test-external

clean::
	rm -rf testsuite/_test_*

# Installation

# The binaries go in BINDIR. We copy ocamlbuild.byte and
# ocamlbuild.native (if available), and also copy the best available
# binary as BINDIR/ocamlbuild.

# The library is put in LIBDIR/ocamlbuild. We copy
# - the META file (for ocamlfind)
# - src/signatures.{mli,cmi,cmti} (user documentation)
# - the files in INSTALL_LIB and INSTALL_LIB_OPT (if available)

# We support three installation methods:
# - standard {install,uninstall} targets
# - findlib-{install,uninstall} that uses findlib for the library install
# - producing an OPAM .install file and not actually installing anything

install-bin-byte:
	mkdir -p $(INSTALL_BINDIR)
	$(CP) ocamlbuild.byte $(INSTALL_BINDIR)/rmlbuild.byte$(EXE)
ifneq ($(OCAML_NATIVE), true)
	$(CP) ocamlbuild.byte $(INSTALL_BINDIR)/rmlbuild$(EXE)
endif

install-bin-native:
	mkdir -p $(INSTALL_BINDIR)
	$(CP) ocamlbuild.native $(INSTALL_BINDIR)/rmlbuild$(EXE)
	$(CP) ocamlbuild.native $(INSTALL_BINDIR)/rmlbuild.native$(EXE)

ifeq ($(OCAML_NATIVE), true)
install-bin: install-bin-byte install-bin-native
else
install-bin: install-bin-byte
endif

install-bin-opam:
	echo 'bin: [' >> rmlbuild.install
	echo '  "ocamlbuild.byte" {"rmlbuild.byte"}' >> rmlbuild.install
ifeq ($(OCAML_NATIVE), true)
	echo '  "ocamlbuild.native" {"rmlbuild.native"}' >> rmlbuild.install
	echo '  "ocamlbuild.native" {"rmlbuild"}' >> rmlbuild.install
else
	echo '  "ocamlbuild.byte" {"rmlbuild"}' >> rmlbuild.install
endif
	echo ']' >> rmlbuild.install
	echo >> rmlbuild.install

install-lib-basics:
	mkdir -p $(INSTALL_LIBDIR)/rmlbuild
	$(CP) META $(INSTALL_SIGNATURES) $(INSTALL_LIBDIR)/rmlbuild

install-lib-basics-opam:
	echo '  "rmlbuild.opam" {"opam"}' >> rmlbuild.install
	echo '  "META"' >> rmlbuild.install
	for lib in $(INSTALL_SIGNATURES); do \
	  echo "  \"$$lib\" {\"$$(basename $$lib)\"}" >> rmlbuild.install; \
	done

install-lib-byte:
	mkdir -p $(INSTALL_LIBDIR)/rmlbuild
	$(CP) $(INSTALL_LIB) $(INSTALL_LIBDIR)/rmlbuild

install-lib-byte-opam:
	for lib in $(INSTALL_LIB); do \
	  echo "  \"$$lib\" {\"$$(basename $$lib)\"}" >> rmlbuild.install; \
	done

install-lib-native:
	mkdir -p $(INSTALL_LIBDIR)/rmlbuild
	$(CP) $(INSTALL_LIB_OPT) $(INSTALL_LIBDIR)/rmlbuild

install-lib-native-opam:
	for lib in $(INSTALL_LIB_OPT); do \
	  echo "  \"$$lib\" {\"$$(basename $$lib)\"}" >> rmlbuild.install; \
	done

ifeq ($(OCAML_NATIVE), true)
install-lib: install-lib-basics install-lib-byte install-lib-native
else
install-lib: install-lib-basics install-lib-byte
endif

install-lib-findlib:
ifeq ($(OCAML_NATIVE), true)
	ocamlfind install rmlbuild \
	  META $(INSTALL_SIGNATURES) $(INSTALL_LIB) $(INSTALL_LIB_OPT)
else
	ocamlfind install rmlbuild \
	  META $(INSTALL_SIGNATURES) $(INSTALL_LIB)
endif

install-lib-opam:
	echo 'lib: [' >> rmlbuild.install
	$(MAKE) install-lib-basics-opam
	$(MAKE) install-lib-byte-opam
ifeq ($(OCAML_NATIVE), true)
	$(MAKE) install-lib-native-opam
endif
	echo ']' >> rmlbuild.install
	echo >> rmlbuild.install

install-man:
	mkdir -p $(INSTALL_MANDIR)/man1
	cp man/rmlbuild.1 $(INSTALL_MANDIR)/man1/rmlbuild.1

install-man-opam:
	echo 'man: [' >> rmlbuild.install
	echo '  "man/rmlbuild.1" {"man1/rmlbuild.1"}' >> rmlbuild.install
	echo ']' >> rmlbuild.install
	echo >> rmlbuild.install

install-doc-opam:
	echo 'doc: [' >> rmlbuild.install
	echo '  "LICENSE"' >> rmlbuild.install
	echo '  "Changes"' >> rmlbuild.install
	echo '  "Readme.md"' >> rmlbuild.install
	echo ']' >> rmlbuild.install

uninstall-bin:
	rm $(BINDIR)/rmlbuild
	rm $(BINDIR)/rmlbuild.byte
ifeq ($(OCAML_NATIVE), true)
	rm $(BINDIR)/rmlbuild.native
endif

uninstall-lib-basics:
	rm $(LIBDIR)/rmlbuild/META
	for lib in $(INSTALL_SIGNATURES); do \
	  rm $(LIBDIR)/rmlbuild/`basename $$lib`;\
	done

uninstall-lib-byte:
	for lib in $(INSTALL_LIB); do\
	  rm $(LIBDIR)/rmlbuild/`basename $$lib`;\
	done

uninstall-lib-native:
	for lib in $(INSTALL_LIB_OPT); do\
	  rm $(LIBDIR)/rmlbuild/`basename $$lib`;\
	done

uninstall-lib:
	$(MAKE) uninstall-lib-basics uninstall-lib-byte
ifeq ($(OCAML_NATIVE), true)
	$(MAKE) uninstall-lib-native
endif
	ls $(LIBDIR)/rmlbuild # for easier debugging if rmdir fails
	rmdir $(LIBDIR)/rmlbuild

uninstall-lib-findlib:
	ocamlfind remove rmlbuild

uninstall-man:
	rm $(INSTALL_MANDIR)/man1/rmlbuild.1

install: check-if-preinstalled
	$(MAKE) install-bin install-lib install-man
uninstall: uninstall-bin uninstall-lib uninstall-man

findlib-install: check-if-preinstalled
	$(MAKE) install-bin install-lib-findlib
findlib-uninstall: uninstall-bin uninstall-lib-findlib

opam-install: check-if-preinstalled
	$(MAKE) rmlbuild.install

rmlbuild.install:
	rm -f rmlbuild.install
	touch rmlbuild.install
	$(MAKE) install-bin-opam
	$(MAKE) install-lib-opam
	$(MAKE) install-man-opam
	$(MAKE) install-doc-opam

check-if-preinstalled:
ifeq ($(CHECK_IF_PREINSTALLED), true)
	if test -d $(shell ocamlc -where)/rmlbuild; then\
	  >&2 echo "ERROR: Preinstalled rmlbuild detected at"\
	       "$(shell ocamlc -where)/rmlbuild";\
	  >&2 echo "Installation aborted; if you want to bypass this"\
	        "safety check, pass CHECK_IF_PREINSTALLED=false to make";\
	  exit 2;\
	fi
endif

# The generic rules

%.cmo: %.ml
	$(OCAMLC) $(COMPFLAGS) -c $<

%.cmi: %.mli
	$(OCAMLC) $(COMPFLAGS) -c $<

%.cmx: %.ml
	$(OCAMLOPT) -for-pack Rmlbuild_pack $(COMPFLAGS) -c $<

clean::
	rm -rf tmp/
	rm -f src/*.cm* *.cm*
ifdef EXT_OBJ
	rm -f src/*$(EXT_OBJ) *$(EXT_OBJ)
endif
ifdef EXT_LIB
	rm -f src/*$(EXT_LIB) *$(EXT_LIB)
endif
	rm -f test/test2/vivi.ml

distclean::
	rm -f rmlbuild.byte rmlbuild.native
	rm -f rmlbuild.install

cleanall: distclean
	rm -f *~ */*~

# The dependencies

depend: beforedepend
	$(OCAMLDEP) -I src src/*.mli src/*.ml > .depend

$(EXTRA_CMI): src/rmlbuild_pack.cmi
$(EXTRA_CMO): src/rmlbuild_pack.cmo src/rmlbuild_pack.cmi
$(EXTRA_CMX): src/rmlbuild_pack.cmx src/rmlbuild_pack.cmi

include .depend

.PHONY: all allopt beforedepend clean configure
.PHONY: install installopt installopt_really depend

