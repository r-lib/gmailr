BASE=$(wildcard R/*.R inst/tests/*.R)

all: install

install: .R_package

.R_package: $(BASE)
	Rscript -e 'library(devtools);install(".", quick=T)'
	touch .R_package

make clean:
	rm -f inst/doc/*.html inst/doc/*.md

#from yihui's knitr Makefile
PKGNAME := $(shell sed -n "s/Package: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGVERS := $(shell sed -n "s/Version: *\([^ ]*\)/\1/p" DESCRIPTION)
PKGSRC  := $(shell basename `pwd`)

# convert markdown to R's NEWS format
news: NEWS.md
	sed -e 's/^-/  -/' -e 's/^## *//' -e 's/^#/\t\t/' < NEWS.md | fmt -80 -s > NEWS

docs: $(BASE)
	Rscript -e 'library(devtools);library(methods);library(utils);document()'

build: $(BASE)
	cd ..;\
	R CMD build $(PKGSRC)

check: build
	cd ..;\
	R CMD check $(PKGNAME)_$(PKGVERS).tar.gz --as-cran

tests: $(BASE)
	Rscript -e 'library(devtools);library(methods);library(utils);test()'
