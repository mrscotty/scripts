#!/usr/bin/env perl
#
# build-core.pl - Build libopenxpki-perl package on debian
#
# Usage:
#
#   build-core.pl [-f] [modname ...]

use Getopt::Long;

my $use_force = 0;

my $result = GetOptions( 'force' => \$use_force, );

my %mods = (
    'core'              => { pkg => 'libopenxpki-perl', },
    'perl-client-api'   => { pkg => 'libopenxpki-client-perl', },
    'deployment'        => { pkg => 'openxpki-deployment', },
    'mason-html-client' => { pkg => 'libopenxpki-client-html-mason-perl', },
    'scep-client'       => { pkg => 'libopenxpki-client-scep-perl', },
    'i18n'              => { pkg => 'openxpki-i18n', },
    'qatest'            => { pkg => 'openxpki-qatest', },
);

# GIVEN: debian package name
# TASK: determine git commit for currently-installed package
# RETURN: git commit hash
sub pkgcommit {
    my $name = shift;
    my $out;

    my $fh;
    open( $fh, "dpkg-query --show -f '\${Description}\\n' '$name'|" )
      or die "Error running dpkg-query: $!";
    while (<$fh>) {
        if (/Git commit hash:\s+(\S+)/) {
            $out = $1;
            last;
        }
    }
    close $fh;
    return $out;
}

## Check status of current working branch
my $gitstatus = `git status --porcelain|wc -l`;

if ( $gitstatus != 0 ) {
    die
"Error: git working directory not clean. Run 'git status' for unresolved changes.";
}

foreach my $target (keys %mods) {
    my ( $rc, $cmd );
    my $mod = $mods{$target};
    $mod->{commit} = pkgcommit( $mod->{pkg} );
    print 40 x '#', "\n";
    print "# Processing module:\n";
    print "#    Package: ", $mod->{pkg},    "\n";
    print "#     Target: ", $target, "\n";
    print "#     Commit: ", $mod->{commit}, "\n";
    print "#  (using force)\n" if $use_force;
    print 40 x '#', "\n";

    if ($use_force) {
        $cmd = 'make ' . $target;
    }
    else {
        $cmd = 'make GITLAZY=' . $mod->{commit} . ' ' . $target;
    }
    $rc = system($cmd);
    if ( $rc != 0 ) {
        die "Error: '$cmd' failed: $?";
    }

    $cmd = 'sudo dpkg -i deb/' . $target . '/' . $mod->{pkg} . '*.deb';
    $rc  = system($cmd);
    if ( $rc != 0 ) {
        die "Error: '$cmd' failed: $?";
    }
}

__END__

  die "NOT FINISHED!"

  pkg = "$@"

  if [ -z "$pkg" ];
then echo
  "No package specified. Defaulting to core, perl-client-api, deployment" pkg =
  "core perl-client-api deployment" fi

  if [ -f /etc/ lsb-release ];
then . /etc/ lsb-release dist =
  "$DISTRIB_CODENAME" else die "ERROR: /etc/lsb-release not found" fi

  if [ "$pkg" == "clean" ];
then

  # don't delete those CPAN packages unnecessarily
  set +x rm -rf ~/openxpki/ dpkg /
  ${dist} /
  binary /
  core rm -rf ~/openxpki/ dpkg /
  ${dist} /
  binary /
  client rm -rf ~/openxpki/ dpkg /
  ${dist} /
  binary /
  client_api set -x exit 1 fi

  cd ~/openxpki || die "Error cd'ing to ~/openxpki"
git pull
cd ~/openxpki/trunk/package/debian || die " Error cd'ing to ~/openxpki/ trunk /
  package /
  debian "

#for i in core client; do
#    rm -f ~/openxpki/dpkg/${dist}/binary/${i}/*.deb deb/${i}/*.deb
#done

for i in $pkg; do
    make $i
done

mkdir -p ~/openxpki/dpkg/${dist}/binary/cpan
mkdir -p ~/openxpki/dpkg/${dist}/binary/core
mkdir -p ~/openxpki/dpkg/${dist}/binary/client
mkdir -p ~/openxpki/dpkg/${dist}/binary/client_api

cp deb/cpan/*.deb ~/openxpki/dpkg/${dist}/binary/cpan/
cp deb/core/*.deb ~/openxpki/dpkg/${dist}/binary/core/
cp deb/client_api/*.deb ~/openxpki/dpkg/${dist}/binary/client_api/
cp deb/client/*.deb ~/openxpki/dpkg/${dist}/binary/client/

(cd ~/openxpki/dpkg && \
        (dpkg-scanpackages ${dist}/binary /dev/null | \
        gzip -9c > ${dist}/binary/Packages.gz) )
