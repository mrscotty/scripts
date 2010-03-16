#!/bin/sh
#
# reset-db.sh - reset workflow data for testing

#select * from certificate_attributes where exists (select * from certificate where certificate_attributes.identifier = certificate.identifier and certificate.role = 'User');
mysql -u openxpki -popenxpki openxpki <<EOF
delete from config;
delete from certificate_attributes;
delete from certificate where role = 'User';
delete from workflow_history;
delete from workflow_context;
delete from workflow;
EOF
