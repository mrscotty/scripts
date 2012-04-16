#!/bin/sh
#
# restart-openxpki.sh
#
# This shell script is for use by the developer during testing. It can
# run as non-root and will restart the openxpki server after truncating
# the log files.
#
# It looks in the same directory for the helper scripts.

dir=`dirname $0`

sudo /etc/init.d/openxpki stop

sudo ${dir}/truncfile \
    /var/openxpki/stderr.log \
    /var/openxpki/openxpki.log

sudo /etc/init.d/openxpki start

echo "###############"
ps -ef | grep ^openxpki
echo "Sleeping before enabling key group"
sleep 2
sudo -u openxpki perl -I/usr/local/lib/perl5/site_perl ${dir}/keygroup.pl
echo "done."
