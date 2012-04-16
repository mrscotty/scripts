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

function pkgcommit {
    dpkg-query --show -f '${Description}\n' "$@" \
        | grep 'Git commit hash:' \
        |awk -F': ' '{print $2}' \
        |awk '{print $1}'
}


## Check status of current working branch
gitstatus=`git status --porcelain|wc -l`
if [ $gitstatus != 0 ]; then
    die "Error: git working directory not clean. Run 'git status' for unresolved changes."
fi

## Get git commit
core_commit=`pkgcommit libopenxpki-perl`
perl_client_api_commit=`pkgcommit libopenxpki-client-perl`
deployment_commit=`pkgcommit openxpki-deployment`
mason_html_client_commit=`pkgcommit libopenxpki-client-html-mason-perl`
scep_client_commit=`pkgcommit libopenxpki-client-scep-perl`
i18n_commit=`pkgcommit openxpki-i18n`
qatest_commit=`pkgcommit openxpki-qatest`

make GITLAZY=$core_commit core && sudo dpkg -i deb/core/libopenxpki-perl*.deb || die "Error building core"
die "NOT FINISHED!"
make GITLAZY=$perl_client_api_commit perl-client-api &&
    make GITLAZY=$deployment_commit deployment &&
    make GITLAZY=$mason_html_client_commit mason-html-client &&
    make GITLAZY=$scep_client_commit scep-client &&
    make GITLAZY=$i18n_commit i18n &&
    make GITLAZY=$qatest_commit qatest

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
