RELEASE=3.2

NOVNCDIR=novnc
NOVNCSRC=${NOVNCDIR}.tgz

ARCH:=$(shell dpkg-architecture -qDEB_BUILD_ARCH)

all: deb

.PHONY: dinstall
dinstall: deb
	dpkg -i ${DEB}

.PHONY: deb
deb ${DEB}: ${TARSRC}
	rm -rf ${NOVNCDIR}
	tar xf ${NOVNCSRC}
	cd ${NOVNCDIR}; dpkg-buildpackage -b -uc -us

.PHONY: download
download:
	rm -rf ${NOVNCDIR}
	git clone git://github.com/kanaka/noVNC ${NOVNCDIR}
	tar czf ${NOVNCSRC} ${NOVNCDIR}

.PHONY: clean
clean:
	rm -rf *~ *_${ARCH}.deb *_all.deb *.changes *.dsc novnc 
