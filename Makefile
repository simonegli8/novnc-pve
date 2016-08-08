RELEASE=4.2

PACKAGE=novnc-pve
PKGREL=8

NOVNCDIR=novnc
NOVNCSRC=${NOVNCDIR}.tgz
NOVNCVER=0.5

ARCH:=$(shell dpkg-architecture -qDEB_BUILD_ARCH)
GITVERSION:=$(shell cat .git/refs/heads/master)

DEB=${PACKAGE}_${NOVNCVER}-${PKGREL}_${ARCH}.deb

all: deb

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}

.PHONY: deb
deb ${DEB}: ${TARSRC}
	rm -rf ${NOVNCDIR}
	tar xf ${NOVNCSRC}
	cp -a debian ${NOVNCDIR}/debian
	cp ${NOVNCDIR}/include/ui.js ${NOVNCDIR}/pveui.js
	# fix file permissions
	chmod 0644 ${NOVNCDIR}/include/jsunzip.js
	echo "git clone git://git.proxmox.com/git/novnc-pve.git\\ngit checkout ${GITVERSION}" > ${NOVNCDIR}/debian/SOURCE
	cd ${NOVNCDIR}; dpkg-buildpackage -b -uc -us
	lintian ${DEB}

.PHONY: download
download:
	rm -rf ${NOVNCDIR}
	git clone git://github.com/kanaka/noVNC ${NOVNCDIR}
	cd ${NOVNCDIR}; git checkout -b local a0e7ab43dca0ce11a713694ee4cf530bd3b17c5a
	tar czf ${NOVNCSRC} ${NOVNCDIR}

.PHONY: upload
upload: ${DEB}
	tar cf - ${DEB}|ssh repoman@repo.proxmox.com upload

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf *~ debian/*~ *_${ARCH}.deb *_all.deb *.changes *.dsc novnc 
