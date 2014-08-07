RELEASE=3.2

PACKAGE=novnc-pve
PKGREL=6

NOVNCDIR=novnc
NOVNCSRC=${NOVNCDIR}.tgz
NOVNCVER=0.4

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
	mv ${NOVNCDIR}/debian ${NOVNCDIR}/debian.org
	cp -a debian ${NOVNCDIR}/debian
	cp pveui.js ${NOVNCDIR}
	# fix file permissions
	chmod 0644 ${NOVNCDIR}/include/jsunzip.js
	echo "git clone git://git.proxmox.com/git/novnc-pve.git\\ngit checkout ${GITVERSION}" > ${NOVNCDIR}/debian/SOURCE
	cd ${NOVNCDIR}; dpkg-buildpackage -b -uc -us
	lintian ${DEB}

.PHONY: download
download:
	rm -rf ${NOVNCDIR}
	git clone git://github.com/kanaka/noVNC ${NOVNCDIR}
	tar czf ${NOVNCSRC} ${NOVNCDIR}

.PHONY: upload
upload: ${DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/${PACKAGE}_*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

.PHONY: distclean
distclean: clean

.PHONY: clean
clean:
	rm -rf *~ debian/*~ *_${ARCH}.deb *_all.deb *.changes *.dsc novnc 
