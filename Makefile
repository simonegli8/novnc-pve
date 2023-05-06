include /usr/share/dpkg/default.mk

PACKAGE=novnc-pve

SRCDIR=novnc
BUILDDIR=$(SRCDIR).tmp
ORIG_SRC_TAR=$(PACKAGE)_$(DEB_VERSION_UPSTREAM).orig.tar.gz

GITVERSION:=$(shell git rev-parse HEAD)

DEB=$(PACKAGE)_$(DEB_VERSION_UPSTREAM_REVISION)_all.deb
DSC=$(PACKAGE)_$(DEB_VERSION_UPSTREAM_REVISION).dsc

all:

$(SRCDIR)/vnc.html: submodule
$(BUILDDIR): $(SRCDIR)/vnc.html
	rm -rf $(BUILDDIR)
	cp -rpa $(SRCDIR) $(BUILDDIR)
	cp -a debian $(BUILDDIR)
	echo "git clone git://git.proxmox.com/git/novnc-pve.git\\ngit checkout $(GITVERSION)" > $(BUILDDIR)/debian/SOURCE

.PHONY: deb
deb: $(DEB)
$(DEB): $(BUILDDIR)
	cd $(BUILDDIR); dpkg-buildpackage -b -uc -us
	lintian $(DEB)
	@echo $(DEB)

$(ORIG_SRC_TAR): $(BUILDDIR)
	tar czf $(ORIG_SRC_TAR) -C $(BUILDDIR) .

.PHONY: dsc
dsc: $(DSC)
$(DSC): $(ORIG_SRC_TAR) $(BUILDDIR)
	cd $(BUILDDIR); dpkg-buildpackage -S -uc -us -d
	lintian $(DSC)

.PHONY: submodule
submodule:
	test -f "$(SRCDIR)/package.json" || git submodule update --init

.PHONY: download
download $(SRCDIR):
	git submodule foreach 'git pull --ff-only origin master'

.PHONY: upload
upload: UPLOAD_DIST ?= $(DEB_DISTRIBUTION)
upload: $(DEB)
	tar cf - $(DEB)|ssh -X repoman@repo.proxmox.com -- upload --product pmg,pve --dist $(UPLOAD_DIST)

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf $(PACKAGE)-[0-9]*/ $() *.deb *.dsc $(PACKAGE)*.tar.[gx]z *.changes *.dsc *.buildinfo *.build

.PHONY: dinstall
dinstall: deb
	dpkg -i $(DEB)
