#!/bin/bash
#
# build-core.sh - Build libopenxpki-perl package on debian

function die {
    echo "$@" >&2
    exit 1
}

pkg="$@"

if [ -z "$pkg" ]; then
    echo "No package specified. Defaulting to core, perl-client-api, deployment"
    pkg="core perl-client-api deployment"
fi

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    dist="$DISTRIB_CODENAME"
else
    die "ERROR: /etc/lsb-release not found"
fi

cd ~/openxpki || die "Error cd'ing to ~/openxpki"
git pull
cd ~/openxpki/trunk/package/debian || die "Error cd'ing to ~/openxpki/trunk/package/debian"

#for i in core client; do
#    rm -f ~/openxpki/dpkg/${dist}/binary/${i}/*.deb deb/${i}/*.deb
#done

for i in $pkg; do
    make $i
done

for i in $i; do
    cp deb/${i}/*.deb ~/openxpki/dpkg/${dist}/binary/${i}/
done

(cd ~/openxpki/dpkg && \
        (dpkg-scanpackages ${dist}/binary /dev/null | \
        gzip -9c > ${dist}/binary/Packages.gz) )
