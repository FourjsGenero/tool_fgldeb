FORMS=$(patsubst %.per,%.42f,$(wildcard *.per))

PROGMOD=fgldeb.42m

all: $(PROGMOD) $(FORMS)

%.42f: %.per
	fglform -M $<

%.42m: %.4gl
	fglcomp -M $<

demo:: all
	make -C demo deb

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
