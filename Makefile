# Build SWI-Prolog installer using Darwinports on MacOS X
#
# Usage (replace version with version you want to build)
#
#	sudo make VERSION=5.9.0

VERSION=

PKG=swi-prolog
DISTFILE=distfiles/$(PKG)/pl-$(VERSION).tar.gz
PORTFILE=$(PKG)/Portfile
URL=http://www.swi-prolog.org/download/devel/src/
SRC=janw@hppc323.few.vu.nl:src/
ZIP=$(PKG)-devel-$(VERSION)-lion-intel.mpkg.zip
SYS=/opt/local/lib/swipl-$(VERSION)
MPKG=$(PKG)-$(VERSION).mpkg
MPKGDIR=$(PKG)/work/$(MPKG)
README=$(MPKGDIR)/Contents/Resources/ReadMe.html
LICENSE=$(MPKGDIR)/Contents/Resources/License.html

all:	clean zip
zip:	$(ZIP)
mpkg:
	rm -rf $(MPKGDIR)
	$(MAKE) $(MPKGDIR)
upload::
	rsync -P $(ZIP) ec:/home/pl/web/download/devel/bin

$(DISTFILE):
	mkdir -p distfiles/$(PKG)
#	wget $(URL)/pl-$(VERSION).tar.gz -O $(DISTFILE)
	rsync $(SRC)/pl-$(VERSION).tar.gz $(DISTFILE)

$(PORTFILE):	$(DISTFILE) Portfile.template
	sed -e "s/@VERSION@/$(VERSION)/" \
	    -e "s/@MD5@/`md5 -q $(DISTFILE)`/" \
		Portfile.template > $(PORTFILE)

$(SYS): $(PORTFILE)
	port -k -d install $(PKG)

$(README):
	cp -p ReadMe.html $(README)

$(LICENSE):
	cp -p License.html $(LICENSE)

$(MPKGDIR): $(SYS)
	port mpkg $(PKG)

$(ZIP): $(MPKGDIR) $(README) $(LICENSE)
	( here=`pwd` && \
	  cd $(PKG)/work && \
	  zip -ry $$here/$(ZIP) $(MPKG) \
	)

clean:	prepare
	rm -f $(DISTFILE)

prepare:
	-port deactivate $(PKG)
	-port uninstall $(PKG)
	-port clean --all $(PKG)
