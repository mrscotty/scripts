#!/usr/bin/env perl

use strict;
use warnings;

our $modlist;
our $cpanrpmdir = $ENV{HOME} . '/xfer/dca04';
our $oxirpmdir = $ENV{HOME} . '/git/code/trunk/package/suse';
our @oxirpms = ( qw( openxpki-i18n perl-openxpki-client perl-openxpki-client-html-mason perl-openxpki-client-html-sc perl-openxpki-client-scep perl-openxpki-core openxpki-deployment) );
our @oxirpmsforce = qw( dca04 );

my $cfgname = 'dca04';
my $oxicfgrpm = `ls -t $ENV{HOME}/rpmbuild/RPMS/*/${cfgname}*.rpm |head -n 1`;
chomp $oxicfgrpm;

sub pause {
    if (@_) {
        print @_;
    }
    print "Press <Enter> to continue...";
    my $junk = <STDIN>;
}

sub ask {
    if (@_) {
        print @_;
    }
    my $bar = $|;
    $|=1;
    print "Continue? [Y/n/q]: ";
    while ( 1 ) {
        my $ans = <STDIN>;
        if ( $ans =~ m/^y/i or $ans =~ m/^\s*$/ ) {
            $|=$bar;
            return 1;
        } elsif ( $ans =~ m/^n/i ) {
            $|=$bar;
            return 0;
        } elsif ( $ans =~ m/^q/i ) {
            exit;
        }

        print "Really continue? [Y/n/q]: ";
    }
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

my @inst = 
  map { s/::/-/g; 'perl-' . $_ }
  grep { not $modlist->{$_}->{update} }
  grep { not $modlist->{$_}->{ignore} }
  sort keys %{$modlist};

my @uninstall      = grep { rpminstalled($_) } @pkglist;
my @forceuninstall = grep { rpminstalled($_) } @updatepkglist;
    
print "FOUND ", scalar(@pkglist),       " PACKAGE(S)\n";
print "FOUND ", scalar(@updatepkglist), " UPDATE PACKAGE(S)\n";
print "PKGLIST: ",        join( ', ', @pkglist ),       "\n";
print "UPDATE PKGLIST: ", join( ', ', @updatepkglist ), "\n";
print "FORCE UNINSTALL: ", join(', ', @forceuninstall), "\n";

my $rc;

if (@forceuninstall) {
    if (ask( "Ready to force uninstall ",
        scalar(@forceuninstall), " package(s)\n" )) {
    $rc = system( 'sudo', 'rpm', '-e', '--nodeps', @forceuninstall );
    $rc = $rc >> 8;
    print "RC=$rc\n";
}
}

if (@uninstall) {
    if ( ask( "Ready to uninstall ", scalar(@uninstall), " package(s)\n" )) {
    $rc = system( 'sudo', 'rpm', '-e', @uninstall );
    $rc = $rc >> 8;
    print "RC=$rc\n";
}
}

if ( ask("Ready to install RPMS found in $cpanrpmdir...\n") ) {
$rc = system("sudo rpm -ivh $cpanrpmdir/*.rpm");
$rc = $rc >> 8;
print "RC=$rc\n";
}

if (ask("Ready to deinstall OpenXPKI RPMS...\n")) {
$rc = system('sudo', 'rpm', '-e', @oxirpms, @oxirpmsforce);
$rc = $rc >> 8;
print "RC=$rc\n";
}

if (ask("Ready to install RPMS found in $oxirpmdir...\n")){
$rc = system("sudo rpm -ivh $oxirpmdir/*.rpm");
$rc = $rc >> 8;
print "RC=$rc\n";
}

if (ask("Ready to (forced) install config RPM $oxicfgrpm...\n")){
$rc = system('sudo', 'rpm', '-ivh', '--force', $oxicfgrpm);
$rc = $rc >> 8;
print "RC=$rc\n";
}

if (ask("Ready to patch dca05 config...\n")){
$rc = system("(cd $ENV{HOME}/git/config && $ENV{HOME}/git/tools/sbin/patch-dca05.sh dca05)");
$rc = $rc >> 8;
print "RC=$rc\n";
}






