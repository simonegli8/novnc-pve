include /usr/share/dpkg/pkg-info.mk

PACKAGE=novnc-pve

SRCDIR=novnc
BUILDDIR=${SRCDIR}.tmp

GITVERSION:=$(shell git rev-parse HEAD)

DEB=${PACKAGE}_${DEB_VERSION_UPSTREAM_REVISION}_all.deb

all: ${DEB}
	@echo ${DEB}

.PHONY: deb
deb: ${DEB}
${DEB}: | submodule
	rm -rf ${BUILDDIR}
	cp -rpa ${SRCDIR} ${BUILDDIR}
	cp -a debian ${BUILDDIR}
	echo "git clone git://git.proxmox.com/git/novnc-pve.git\\ngit checkout ${GITVERSION}" > ${BUILDDIR}/debian/SOURCE
	cd ${BUILDDIR}; dpkg-buildpackage -rfakeroot -b -uc -us
	lintian ${DEB}
	@echo ${DEB}

.PHONY: submodule
submodule:
	test -f "${SRCDIR}/vnc.html" || git submodule update --init

.PHONY: download
download ${SRCDIR}:
	git submodule foreach 'git pull --ff-only origin master'

.PHONY: upload
upload: ${DEB}
	tar cf - ${DEB}|ssh -X repoman@repo.proxmox.com -- upload --product pmg,pve --dist stretch

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf *~ debian/*~ *.deb ${BUILDDIR} *.changes *.dsc *.buildinfo

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}
