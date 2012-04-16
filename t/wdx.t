#!/usr/bin/env perl
#
use strict;
use warnings;

use Test::More tests => 10;

my $wdx = 'bin/wdx';

my $rc;
my $config;
my $got;
my $expected;

$config = 't/wdx.d/init.cfg';
my $info = `$wdx --config $config --info`;
my %info =
  map { s/^\s+//g; $_ } map { split( /:\s+/, $_, 2 ); } split( "\n", $info );
is( $info{Base}, 't/wdx.d/init.d', 'info has correct dir' );

$got       = `$wdx --config $config cat test1`;
$expected = "test123\ntest456\n";
is( $got, $expected, 'wdx cat LOCAL');

if ( -f 't/wdx.d/init.d/test2' ) {
    unlink('test2') or die "Error removing t/wdx.d/init.d/test2: $@";
}
$rc       = system("$wdx --config $config put t/wdx.d/init.d/test1 t/wdx.d/test2");
$got      = `cat t/wdx.d/test2`;
is( $got, $expected, 'wdx put LOCAL REMOTE(FS)' );

