#!/bin/bash
#
# build-core.sh - Build libopenxpki-perl package on debian

function die {
    echo "$@" >&2
    # only exit if running as script and not as interactive bash
    # shell (i.e. cut-n-paste)
    if [ $0 != "-bash" ]; then
        exit 1
    fi
}

## Check status of current working branch
gitstatus=`git status --porcelain|wc -l`
if [ $gitstatus != 0 ]; then
    die "Error: git working directory not clean. Run 'git status' for unresolved changes."
fi

die "NOT FINISHED!"

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

if [ "$pkg" == "clean" ]; then
    # don't delete those CPAN packages unnecessarily
    set +x
    rm -rf ~/openxpki/dpkg/${dist}/binary/core
    rm -rf ~/openxpki/dpkg/${dist}/binary/client
    rm -rf ~/openxpki/dpkg/${dist}/binary/client_api
    set -x
    exit 1
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

mkdir -p ~/openxpki/dpkg/${dist}/binary/cpan
mkdir -p ~/openxpki/dpkg/${dist}/binary/core
mkdir -p ~/openxpki/dpkg/${dist}/binary/client
mkdir -p ~/openxpki/dpkg/${dist}/binary/client_api

cp deb/cpan/*.deb ~/openxpki/dpkg/${dist}/binary/cpan/
cp deb/core/*.deb ~/openxpki/dpkg/${dist}/binary/core/
cp deb/client_api/*.deb ~/openxpki/dpkg/${dist}/binary/client_api/
cp deb/client/*.deb ~/openxpki/dpkg/${dist}/binary/client/

(cd ~/openxpki/dpkg && \
        (dpkg-scanpackages ${dist}/binary /dev/null | \
        gzip -9c > ${dist}/binary/Packages.gz) )
