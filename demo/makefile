MODULES=\
    mod5.42m\
    main.42m\
    mod2.42m\
    mod3.42m\
    mod4.42m\
    ttydemo.42m

SUBDIRS=sub

all:: subdirs 

include ../Makeincl

run: all
	FGLLDPATH=sub fglrun main.42r

#FIXME:
mod5.4gl: sub/mod5.4gl
	cp sub/mod5.4gl .
 
deb: all
	FGLLDPATH=sub fglrun ../fgldeb.42m main

