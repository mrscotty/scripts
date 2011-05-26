#!/bin/sh
#
# deploy-test.sh
#
# This shell script is for use by the developer during testing. It can
# run as non-root and will stop openxpki, update the packages
# and start the openxpki server after truncating
# the log files.
#
# It looks in the same directory for the helper scripts.

set -x

code="$HOME/git/code"
config="$HOME/git/config"
tools="$HOME/git/tools"
target="dca04"
codever=0.9.1552-1


coderpms="perl-openxpki-client perl-openxpki-core perl-openxpki-client-html-mason openxpki-deployment perl-openxpki-client-html-sc openxpki-i18n perl-openxpki-client-scep"

function die {
  echo "ERROR: $*" 1>&2
  exit 1
}

dir=`dirname $0`

echo "############################################################"
echo "# Stop OpenXPKI and truncate logs"
echo "############################################################"
sudo /etc/init.d/openxpki stop

sudo $tools/sbin/truncfile \
    /var/openxpki/stderr.log \
    /var/openxpki/openxpki.log



echo "############################################################"
echo "# Repackage and install"
echo "############################################################"


cd $code/trunk/package/suse || die "Can't cd to $code/trunk/package/suse"
make public || die "'make public' failed"

sudo rpm -e $target $coderpms || die "failed to remove code packages"
sudo rpm -ivh *x86_64.rpm || die "failed to install code packages"

cd $config || die "Can't cd to $config"
make config TARGET=$target || die "'make config TARGET=$target' failed"
sudo rpm -ivh --force /usr/src/packages/RPMS/x86_64/${target}-*x86_64.rpm || "install config rpm failed"
bin/patch-dca05.sh || die "patch dca05 failed"

echo "############################################################"
echo "# Start OpenXPKI"
echo "############################################################"

sudo /etc/init.d/openxpki start || die "Failed to start openxpki"

echo "###############"
ps -ef | grep ^openxpki
echo "Sleeping before enabling key group"
sleep 2
sudo -u openxpki perl -I/usr/local/lib/perl5/site_perl $tools/sbin/keygroup.pl
echo "done."
