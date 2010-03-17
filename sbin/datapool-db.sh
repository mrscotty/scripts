#!/bin/sh
#
# datapool-db.sh - Add datapool table to db

mysql -u root -psecret openxpki <<EOF
DROP TABLE IF EXISTS 'datapool';
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE 'datapool' (
 'pki_realm' varchar(255) NOT NULL,
 'namespace' varchar(255) NOT NULL,
 'datapool_key' varchar(255) NOT NULL,
 'datapool_value' text,
 'encryption_key' varchar(255) default NULL,
 'notafter' decimal(49,0) default NULL,
 'last_update' decimal(49,0) default NULL,
 PRIMARY KEY  ('pki_realm','namespace','datapool_key')
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client;
EOF
