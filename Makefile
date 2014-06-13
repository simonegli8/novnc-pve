RELEASE=3.2

PACKAGE=novnc-pve
PKGREL=1

NOVNCDIR=novnc
NOVNCSRC=${NOVNCDIR}.tgz
NOVNCVER=0.4

ARCH:=$(shell dpkg-architecture -qDEB_BUILD_ARCH)

DEB=${PACKAGE}_${NOVNCVER}-${PKGREL}_${ARCH}.deb

all: deb

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}

.PHONY: deb
deb ${DEB}: ${TARSRC}
	rm -rf ${NOVNCDIR}
	tar xf ${NOVNCSRC}
	mv ${NOVNCDIR}/debian ${NOVNCDIR}/debian.org
	cp -a debian ${NOVNCDIR}/debian 
	cd ${NOVNCDIR}; dpkg-buildpackage -b -uc -us
	lintian ${DEB}

.PHONY: download
download:
	rm -rf ${NOVNCDIR}
	git clone git://github.com/kanaka/noVNC ${NOVNCDIR}
	tar czf ${NOVNCSRC} ${NOVNCDIR}

.PHONY: clean
clean:
	rm -rf *~ debian/*~ *_${ARCH}.deb *_all.deb *.changes *.dsc novnc 
