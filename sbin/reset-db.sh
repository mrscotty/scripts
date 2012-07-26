#!/bin/sh
#
# reset-db.sh - reset workflow data for testing

if [ -f /applications/oracle/10.2.0.4/bin/sqlplus ]; then
    . /etc/sysconfig/openxpki && sqlplus / <<EOF
delete from l2openxpki.config;
delete from l2openxpki.certificate_attributes;
delete from l2openxpki.certificate where role = 'User';
delete from l2openxpki.workflow_history;
delete from l2openxpki.workflow_context;
delete from l2openxpki.workflow;
EOF
else
#select * from certificate_attributes where exists (select * from certificate where certificate_attributes.identifier = certificate.identifier and certificate.role = 'User');
mysql -u openxpki -popenxpki openxpki <<EOF
delete from config;
delete from certificate_attributes;
delete from certificate where role = 'User';
delete from workflow_history;
delete from workflow_context;
delete from workflow;
EOF
fi
