#!/usr/bin/perl -w
#
# TODO: add datapool manipulation support to openxpkiadm
#
# This requires $pkcs10 to contain the CSR, which can be generated with the
# following commands:
#
#   openssl genrsa -out /tmp/sc_pers_csr.key 1024

use strict;

use OpenXPKI::Tests;
use OpenXPKI::Client;
use Data::Dumper;
use Carp;

# use test deployment
my $instancedir = '';
my $socketfile  = $instancedir . '/var/openxpki/openxpki.socket';
my $pidfile     = $instancedir . '/var/openxpki/openxpki.pid';

my $wf_type   = 'I18N_OPENXPKI_WF_TYPE_SMARTCARD_PERSONALIZATION';
my $USER      = 'ca';
my $USERROLE = 'CA Operator';

my ( $msg, $wf_id, $wf_info, $client, $pkcs10, $csr );

#
# $client = wfconnect( USER, PASS );
#
sub wfconnect {
    my ( $u, $p ) = @_;
    my $c = OpenXPKI::Client->new(
        {   TIMEOUT    => 100,
            SOCKETFILE => $instancedir . '/var/openxpki/openxpki.socket',
        }
    );
    login(
        {   CLIENT   => $c,
            USER     => $u,
            PASSWORD => $p,
        }
    ) or die "Login as $c failed: $@";
    return $c;
}

sub wfdisconnect {
    my $c = $_[0] || $client;
    eval { $c && $c->send_receive_service_msg('LOGOUT'); };
    unless ( $_[0] ) {
        $client = undef;
    }
}

#
# usage: my $msg = wfexec( ID, ACTIVITY, { PARAMS } );
#
sub wfexec {
    return wfexec2( $client, @_ );

    my ( $id, $act, $params ) = @_;
    my $msg;
    croak("Unable to exec action '$act' on closed connection")
        unless defined $client;

    $msg = $client->send_receive_command_msg(
        'execute_workflow_activity',
        {   'ID'       => $id,
            'ACTIVITY' => $act,
            'PARAMS'   => $params,
            'WORKFLOW' => $wf_type,
        },
    );
    return $msg;

}

#
# usage: my $msg = wfexec( CLIENT, ID, ACTIVITY, { PARAMS } );
#
sub wfexec2 {
    my ( $client, $id, $act, $params ) = @_;
    my $msg;

    croak("Unable to exec action '$act' on closed connection")
        unless defined $client;

    $msg = $client->send_receive_command_msg(
        'execute_workflow_activity',
        {   'ID'       => $id,
            'ACTIVITY' => $act,
            'PARAMS'   => $params,
            'WORKFLOW' => $wf_type,
        },
    );
    return $msg;
}

#
# usage: my $state = wfstate( USER, PASS, ID );
# Note: $@ contains either error message or Dumper($msg)
#
sub wfstate {
    my ( $user, $pass, $id ) = @_;
    my ( $msg, $state );
    my $disc = 0;
    $@ = '';

    unless ($client) {
        $disc++;
        unless ( $client = wfconnect( $user, $pass ) ) {
            $@ = "Failed to connect as $user";
            return;
        }
    }
    $msg = $client->send_receive_command_msg( 'get_workflow_info',
        { 'WORKFLOW' => $wf_type, 'ID' => $id, } );
    if ( is_error_response($msg) ) {
        $@ = "Error running get_workflow_info: '" . Dumper($msg) . "'";
        return;
    }
    $@ = Dumper($msg);
    if ($disc) {
        wfdisconnect();
    }
    return $msg->{PARAMS}->{WORKFLOW}->{STATE};
}

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

my %puk_data = ( 
   gem2_001 => '12345',
   gem2_002 => '22345',
   gem2_003 => '32345',
   gem2_004 => '42345',
   gem2_005 => '52345',
);

$client = wfconnect($USER, $USERROLE);
$msg = $client->send_receive_command_msg(
    'set_data_pool_entry',
    { 'SECRET' => 'default', 'VALUE' => '1234567890', },
);
mustSucceed($msg);

