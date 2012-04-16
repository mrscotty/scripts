#!/usr/bin/perl -w
#
use strict;

# Install it
my $ret = system(qw( aptitude -y install slapd ldap-utils ));
die "Error installing slapd: $0" unless ( $ret == 0 );

# Snatch olcRootPW
open( PW, '</etc/ldap/slapd.d/cn=config/olcDatabase={1}hdb.ldif' )
    or die "Error opening olcDatabase=\{1\}hdb.ldif: $!";

my $rootpw = grep 'olcRootPW' < PW >;
close PW;

# write to config.ldif
open( CFG, '>/etc/ldap/slapd.d/cn=config/olcDatabase={0}config.ldif' )
    or die "Error opening olcDatabase=\{0\}config.ldif: $!";

# restart ldap
$ret = system( qw( /etc/init.d/slapd restart ) );
die "Error restarting slapd: $0" unless ( $ret == 0 );

# Add schema for scb

