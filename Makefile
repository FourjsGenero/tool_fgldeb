FORMS=$(patsubst %.per,%.42f,$(wildcard *.per))

PROGMOD=fgldeb.42m
ifndef FGLDIR
  $(error FGLDIR must be set)
endif
#quote against the crazy GST pathes containing spaces
MYFGLDIR=$(shell FGLDIR="$(FGLDIR)";echo $${FGLDIR// /\\ })

#if we have fgldb in $FGLDIR/bin we can attach to fgl processes
ifneq ($(wildcard $(MYFGLDIR)/bin/fgldb),)
FGLCOMPDEFINES=-D HAVE_FGLDB
endif


all: $(PROGMOD) $(FORMS)

%.42f: %.per
	fglform -M $<

%.42m: %.4gl
	fglcomp -M $(FGLCOMPDEFINES) $<

demo:: all
	make -C demo deb

attachdemo:: all
	make -C demo attach

define pack
	fglscriptify $(1) icons/*.png *.per fgldeb.msg fgldeb.4ad fgldeb.4st fgldeb.4tb fgldeb.4gl
endef

dist:: 
	rm -f script/fgldeb script/fgldeb.bat
	$(call pack,-o script/fgldeb)
	$(call pack,-o script/fgldeb.bat)

clean_prog::
	rm -f *.42?

clean:: clean_prog
	make -C demo clean

echo:
	echo "FGLDIR=$(FGLDIR)"
