NAME := cjdns-hello
INSTALLROOT ?= installdir
INSTALLBIN := $(INSTALLROOT)/usr/bin
INSTALLLIB := $(INSTALLROOT)/usr/share/perl5
INSTALLSYS := $(INSTALLROOT)/etc/systemd/system
OUTPUTROOT := output

describe := $(shell git describe --tags --long --dirty)
debfile := $(NAME)_$(describe)_all.deb

build: deps clean
	fatpack file cjdns-hello.pl > $(NAME)
	chmod +x $(NAME)
	echo "=== run ./cjdns-hello daemon to start ==="

deps:
	cpanm --sudo --installdeps .

clean:
	rm -f $(NAME)
	rm -rf $(INSTALLROOT)
	rm -rf $(OUTPUTROOT)

install: build
	mkdir -p $(INSTALLBIN) $(INSTALLSYS) $(OUTPUTROOT)
	cp -pr cjdns-hello $(INSTALLBIN)
	cp -pr systemd/cjdns-hello.service $(INSTALLSYS)
 
deb: $(debfile)

$(debfile): debian/changelog
	debuild --no-tgz-check -i -us -uc -b
	mv ../$(debfile) $(OUTPUTROOT)/

debian/changelog: deb_deps
	rm -f debian/changelog
	dch --create -v $(describe) --package $(NAME) --empty
	@echo "=== Using this changelog"
	@cat debian/changelog

deb_deps:
	sudo apt-get install -y debhelper devscripts fakeroot

run:
	morbo -w . -l http://\*:8080 cjdns-hello.pl
