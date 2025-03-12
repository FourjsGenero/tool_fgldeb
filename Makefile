FORMS=$(patsubst %.per,%.42f,$(wildcard *.per))

PROGMOD=fgldeb.42m
ifndef FGLDIR
  $(error FGLDIR must be set)
endif

ifneq (,$(shell which fgldb))
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

cpassets:: all
	rm -rf dist
	mkdir dist
	mkdir dist/fgldeb
	mkdir dist/fgldeb/demo
	cp fgldeb fgldeb.bat fgldeb.42m *.42f fgldeb.msg fgldeb.4ad fgldeb.4st fgldeb.4tb dist/fgldeb
	cp -a icons/ dist/fgldeb/icons/
	make -C demo
	cp demo/debugsimple.42m demo/simple*.4gl demo/simple*.42m dist/fgldeb/demo

tgz:: cpassets
	rm -f fgldeb.tgz
	cd dist&&tar cvfz ../fgldeb.tgz fgldeb/

zip:: cpassets
	rm -f fgldeb.zip
	cd dist&&zip -r ../fgldeb.zip fgldeb/

testtgz:: tgz
	rm -rf testdist
	mkdir testdist
	cd testdist&&tar xvzf ../fgldeb.tgz&&cd fgldeb/demo&&fglrun debugsimple

testzip:: zip
	rm -rf testdist
	mkdir testdist
	cd testdist&&unzip ../fgldeb.zip&&cd fgldeb/demo&&fglrun debugsimple

define scriptify
	fglscriptify $(1) icons/*.png *.per fgldeb.msg fgldeb.4ad fgldeb.4st fgldeb.4tb fgldeb.4gl
endef

#if you have installed fglscriptify from https://github.com/leopatras/fglscriptify.git
scriptify::
	rm -f script/fgldeb script/fgldeb.bat
	$(call scriptify,-o script/fgldeb)
	$(call scriptify,-o script/fgldeb.bat)

clean_prog::
	rm -f *.42?

clean:: clean_prog
	rm -f *.tgz *.zip *.fgldeb
	rm -rf dist testdist
	make -C demo clean

echo:
	echo "FGLDIR=$(FGLDIR)"
