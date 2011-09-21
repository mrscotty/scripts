#!/bin/sh
#
# build-core.sh - Build libopenxpki-perl package on debian

die {
    echo "$@" >&2
    exit 1
}

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    dist="$DISTRIB_CODENAME"
else
    die "ERROR: /etc/lsb-release not found"
fi

cd ~/openxpki || die "Error cd'ing to ~/openxpki"
git pull
cd ~/openxpki/trunk/package/debian || die "Error cd'ing to ~/openxpki/trunk/package/debian"

rm -f ~/openxpki/dpkg/${dist}/binary/core/*.deb

cp deb/core/*.deb ~/openxpki/dpkg/${dist}/binary/core/

(cd ~/openxpki/dpkg && \
        (dpkg-scanpackages ${dist}/binary /dev/null | \
        gzip -9c > ${dist}/binary/Packages.gz) )
