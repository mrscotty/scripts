#!/bin/sh

openxpkictl stop
>/var/openxpki/stderr.log
#  --debug '.*LDAP.*:128' \
#  --debug '.*WorkflowCondition.*:128' \
#  --debug '.*Notification.*:128' \
#  --debug '.*Dispatcher.*:128' \
openxpkictl \
  --debug '.*GetLDAPData.*:128' \
  start
echo "###############"
ps -ef | grep ^openxpki
echo "Sleeping before enabling key group"
sleep 2
/etc/openxpki/local/etc/keygroup.pl
echo "done."
