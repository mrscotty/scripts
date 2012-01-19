#!/usr/bin/env perl

use strict;
use warnings;

our $modlist;
our $rpmdir = $ENV{HOME} . '/xfer/dca04';

sub pause {
    if (@_) {
        print @_;
    }
    print "Press <Enter> to continue...";
    my $junk = <STDIN>;
}

# return true value if given RPM package is installed
sub rpminstalled {
    my $name = shift;
    my $rc   = system("rpm -q '$name' >/dev/null 2>&1");
    $rc = $rc >> 8;
    return not $rc;
}

my $cfgfile =
  $ENV{HOME} . '/git/openxpki/trunk/package/suse/cpan/SLES-10-2-cpan-build.cfg';

do $cfgfile or die "Error sourcing '$cfgfile': $@";

my @pkglist =
  map { s/::/-/g; 'perl-' . $_ }
  grep { not $modlist->{$_}->{update} }
  grep { not $modlist->{$_}->{ignore} }
  sort keys %{$modlist};

my @updatepkglist =
  map { s/::/-/g; 'perl-' . $_ }
  grep { $modlist->{$_}->{update} }
  grep { not $modlist->{$_}->{ignore} }
  sort keys %{$modlist};

print "FOUND ", scalar(@pkglist),       " PACKAGE(S)\n";
print "FOUND ", scalar(@updatepkglist), " UPDATE PACKAGE(S)\n";
print "PKGLIST: ",        join( ', ', @pkglist ),       "\n";
print "UPDATE PKGLIST: ", join( ', ', @updatepkglist ), "\n";

my @uninstall      = grep { rpminstalled($_) } @pkglist;
my @forceuninstall = grep { rpminstalled($_) } @updatepkglist;

my $rc;

if (@forceuninstall) {
    pause( "Ready to force uninstall ",
        scalar(@forceuninstall), " package(s)\n" );
    $rc = system( 'sudo', 'rpm', '-e', '--nodeps', @forceuninstall );
    $rc = $rc >> 8;
    print "RC=$rc\n";
}

if (@uninstall) {
    pause( "Ready to uninstall ", scalar(@uninstall), " package(s)\n" );
    $rc = system( 'sudo', 'rpm', '-e', @uninstall );
    $rc = $rc >> 8;
    print "RC=$rc\n";
}

pause("Ready to install RPMS found in $rpmdir...\n");
$rc = system("sudo rpm -ivh $rpmdir/*.rpm");
$rc = $rc >> 8;
print "RC=$rc\n";




