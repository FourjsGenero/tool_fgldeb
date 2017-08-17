FORMS=$(patsubst %.per,%.42f,$(wildcard *.per))

PROGMOD=fgldeb.42m

all: $(PROGMOD) $(FORMS) demo

%.42f: %.per
	fglform -M $<

%.42m: %.4gl
	fglcomp -M $<

demo::
	make -C demo

run:: all
	fglrun fgldeb demo/main.42m

define pack
	fglscriptify $(1) icons/*.png *.per fgldeb.msg fgldeb.4ad fgldeb.4st fgldeb.4tb fgldeb.4gl
endef

dist:: 
	rm -f fgldeb fgldeb.bat
	$(call pack,)
	$(call pack,-o fgldeb.bat)

clean::
	rm -f *.42?
	make -C demo clean
