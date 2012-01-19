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
#
# IMPORTANT: This requires that the config working repo is clean!

my $HOME      = $ENV{HOME};
my $code      = "$HOME/git/code";
my $config    = "$HOME/git/config";
my $tools     = "$HOME/git/tools";
my $deftarget = "dca04";
my $target    = 'dbkppki01';
my $rel       = '';

my %skip = ( make_code => 1, );

my $configbranch = `cd $config && git symbolic-ref HEAD 2>/dev/null`;
if ( not $configbranch ) {
    die "Git working repo in '$config' has detached HEAD";
}
$configbranch =~ s,^refs/heads/,,;

if ( $configbranch =~ m,^(rel/[^/]+)/(.+)$, ) {
    $rel    = $1;
    $target = $2;
}
else {
    $target = $configbranch;
}

my @coderpms =
  qw( perl-openxpki-client perl-openxpki-core perl-openxpki-client-html-mason openxpki-deployment perl-openxpki-client-html-sc openxpki-i18n perl-openxpki-client-scep );

my @configrpms = map { chomp; $_ } grep { /^(dbkppki|dbkrpki|dca0)/ } `rpm -qa`;

my $dir = `dirname $0`;
chomp $dir;

print "############################################################", "\n";
print "# Stop OpenXPKI and truncate logs",                            "\n";
print "############################################################", "\n";
system(qw( sudo /etc/init.d/openxpki stop));

system( 'sudo', $tools . '/sbin/truncfile',
    '/var/openxpki/stderr.log', '/var/openxpki/openxpki.log' );

print "############################################################", "\n";
print "# Repackage and install",                                      "\n";
print "############################################################", "\n";

if ( not $skip{make_code} ) {
    print "running 'make public'\n";
    system("cd $code/trunk/package/suse && make public") == 0
      or die "ERROR running 'make public' in $code/trunk/packages/suse: $?";
}

print "removing previous RPMS ", join( ', ', @configrpms, @coderpms ), "\n";
system( 'sudo', 'rpm', '-e', @configrpms, @coderpms ) == 0
  or warn "#########################\n",
  "ERROR removing previous RPMs: $?", "\n",
  "#########################\n",
  ;

print "Installing code RPMs\n";
system( 'sudo', 'rpm', '-ivh', $code . '/trunk/package/suse/*x86_64.rpm' ) == 0
  or die "Error installing RPMs: $?";

print "running 'make config TARGET=$target'\n";
system("cd $config && make config TARGET=$target") == 0
  or die "Error running 'make config TARGET=$target' in '$config': $?";

print "installing config for '$target'\n";
system( 'sudo', 'rpm', '-ivh', '--force',
    '/usr/src/packages/RPMS/x86_64/' . ${target} . '-*x86_64.rpm' ) == 0
  or die "Error installing config RPM: $?";

die "here";
system( $tools . '/sbin/patch-dca05.sh' ) == 0
  or die "Error patching for dca05: $?";

print "############################################################", "\n";
print "# Start OpenXPKI",                                             "\n";
print "############################################################", "\n";

system(qw(sudo /etc/init.d/openxpki start)) == 0
  or die "Failed to start openxpki: $?";

print "###############", "\n";
system("ps -ef | grep ^openxpki");
print "Sleeping before enabling key group", "\n";
sleep 2;
system( qw(sudo -u openxpki perl -I/usr/local/lib/perl5/site_perl ),
    $tools . '/sbin/keygroup.pl' ) == 0
  or die "Error starting openxpki: $?";

print "done.", "\n";
