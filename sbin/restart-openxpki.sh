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

sudo openxpki openxpkictl stop

sudo openxpki ${dir}/truncfile \
    /var/openxpki/stderr.log \
    /var/openxpki/openxpki.log

#  --debug '.*WorkflowCondition.*:128' \
#  --debug '.*Notification.*:128' \
#  --debug '.*Dispatcher.*:128' \
#  --debug '.*Datapool.*:128' \
sudo openxpki openxpkictl \
  --debug '.*CardAdm.*:64' \
  --debug '.*FetchPUK.*:64' \
  --debug '.*Default.*:64' \
  start
echo "###############"
ps -ef | grep ^openxpki
echo "Sleeping before enabling key group"
sleep 2
${dir}/keygroup.pl
echo "done."
