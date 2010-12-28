#!/bin/sh

openxpkictl stop
>/var/openxpki/stderr.log
>/var/openxpki/openxpki.log
#  --debug '.*WorkflowCondition.*:128' \
#  --debug '.*Notification.*:128' \
#  --debug '.*Dispatcher.*:128' \
#  --debug '.*Datapool.*:128' \
openxpkictl \
  --debug '.*CardAdm.*:64' \
  start
echo "###############"
ps -ef | grep ^openxpki
echo "Sleeping before enabling key group"
sleep 2
/etc/openxpki/local/sbin/keygroup.pl
echo "done."
