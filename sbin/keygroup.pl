#!/usr/bin/perl -w
#
# TODO: add keygroup activation to openxpkiadm
#
# This requires $pkcs10 to contain the CSR, which can be generated with the
# following commands:
#
#   openssl genrsa -out /tmp/sc_pers_csr.key 1024

use strict;
use warnings;

use OpenXPKI::Tests::More;
use Carp;
use Data::Dumper;

sub maySucceed {
    my $msg = shift;
    croak '$msg not defined' unless defined $msg;
    if ( $msg->{SERVICE_MSG} eq 'ERROR' ) {
        $@ = Dumper($msg);
        return;
    }
    else {
        return $msg;
    }
}

sub mustSucceed {
    my $msg;
    $msg = maySucceed( $_[0] );
    if ($msg) {
        return $msg;
    }
    else {
        croak $@;
    }
}

# use test deployment
my $instancedir = '';
my $socketfile  = $instancedir . '/var/openxpki/openxpki.socket';
my $pidfile     = $instancedir . '/var/openxpki/openxpki.pid';

my $wf_type  = 'I18N_OPENXPKI_WF_TYPE_SMARTCARD_PERSONALIZATION';
my $USER     = 'ca';
my $USERROLE = 'CA Operator';

my $test = OpenXPKI::Tests::More->new(
    {
        socketfile => $socketfile,
        realm      => 'User TEST CA'
    },
);

$test->connect( user => $USER, password => $USERROLE );
my $client = $test->get_client();

my $msg =
  $client->send_receive_command_msg( 'set_secret_part',
    { 'SECRET' => 'default', 'VALUE' => '1234567890', },
  );
mustSucceed($msg);

