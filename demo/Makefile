MODS=$(patsubst %.4gl,%.42m,$(wildcard *.4gl))

%.42m: %.4gl 
	fglcomp -M $<


all: $(MODS) sub/mod5.42m
	echo $(MODS)

sub/mod5.42m: sub/mod5.4gl
	fglcomp -M $<
	mv mod5.42m sub

run: all
	FGLLDPATH=sub fglrun main

deb: all
	FGLLDPATH=sub FGLSOURCEPATH=sub ../fgldeb main


attach: all
	fglrun debugsimple

clean: 
	rm -f *.42? sub/*.42m simple.pid

