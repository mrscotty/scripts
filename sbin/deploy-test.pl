#!/usr/bin/env perl
#
# deploy-test.sh [ REL [ TARGET ] ]
#
# This shell script is for use by the developer during testing. It can
# run as non-root and will stop openxpki, update the packages
# and start the openxpki server after truncating
# the log files.
#
# It looks in the same directory for the helper scripts.
#
# For the code packages, the current branch in the code repository is used.
#
# For the config package, the target is either the name of the current 
# branch in the config working repo or, if the branch name is in the format
# "rel/.+/.+", then "rel/.+/" is removed. 
#
# For the dca05-specific patches, the branch dca05 is used. If a release 
# string was found in the current config branch, that string is prepended
# to the "dca05" name.

my $HOME = $ENV{HOME};
my $code="$HOME/git/code";
my $config="$HOME/git/config";
my $tools="$HOME/git/tools";
my $deftarget="dca04";

my @coderpms=qw( perl-openxpki-client perl-openxpki-core perl-openxpki-client-html-mason openxpki-deployment perl-openxpki-client-html-sc openxpki-i18n perl-openxpki-client-scep );

my $dir=`dirname $0`;
chomp $dir;

print "############################################################", "\n";
print "# Stop OpenXPKI and truncate logs", "\n";
print "############################################################", "\n";
system( qw( sudo /etc/init.d/openxpki stop) );

system( 'sudo', $tools . '/sbin/truncfile', '/var/openxpki/stderr.log', '/var/openxpki/openxpki.log' );

print "############################################################", "\n";
print "# Repackage and install", "\n";
print "############################################################", "\n";


system("cd $code/trunk/package/suse && make public")
    or die "ERROR running 'make public' in $code/trunk/packages/suse: $!";

system('sudo', 'rpm', '-e', $target, @coderpms) 
    or die "ERROR removing previous RPMs: $!";

system('sudo', 'rpm', '-ivh', $code . '/trunk/package/suse/*x86_64.rpm')
    or die "Error installing RPMs: $!";

system("cd $config && make config TARGET=$target")
    or die "Error running 'make config TARGET=$target' in '$config': $!";

system('sudo', 'rpm', '-ivh', '--force', '/usr/src/packages/RPMS/x86_64/' . ${target} . '-*x86_64.rpm')
    or die "Error installing config RPM: $!";

system($tools . '/bin/patch-dca05.sh')
    or die "Error patching for dca05: $!";

print "############################################################", "\n";
print "# Start OpenXPKI", "\n";
print "############################################################", "\n";

system ( qw(sudo /etc/init.d/openxpki start) )
    or die "Failed to start openxpki";

print "###############", "\n";
system("ps -ef | grep ^openxpki");
print "Sleeping before enabling key group", "\n";
sleep 2;
system( qw(sudo -u openxpki perl -I/usr/local/lib/perl5/site_perl ), $tools . '/sbin/keygroup.pl')
    or die "Error starting openxpki: $!";

print "done.", "\n";
