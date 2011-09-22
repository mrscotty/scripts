#!/bin/bash
#
# build-core.sh - Build libopenxpki-perl package on debian

function die {
    echo "$@" >&2
    exit 1
}

pkg="$1"

if [ -n "$pkg" ]; then
    die "No package specified. try 'core' or 'deployment'"
fi

die "whoa there, cowboy!"

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    dist="$DISTRIB_CODENAME"
else
    die "ERROR: /etc/lsb-release not found"
fi

cd ~/openxpki || die "Error cd'ing to ~/openxpki"
git pull
cd ~/openxpki/trunk/package/debian || die "Error cd'ing to ~/openxpki/trunk/package/debian"

rm -f ~/openxpki/dpkg/${dist}/binary/${pkg}/*.deb deb/${pkg}/*.deb

make $pkg

cp deb/${pkg}/*.deb ~/openxpki/dpkg/${dist}/binary/${pkg}/

(cd ~/openxpki/dpkg && \
        (dpkg-scanpackages ${dist}/binary /dev/null | \
        gzip -9c > ${dist}/binary/Packages.gz) )
