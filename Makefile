FORMS=$(patsubst %.per,%.42f,$(wildcard *.per))

PROGMOD=fgldeb.42m

all: $(PROGMOD) $(FORMS)

%.42f: %.per
	fglform -M $<

%.42m: %.4gl
	fglcomp -M $<

clean::
	rm -f *.42?
