#!/bin/sh
#
# patch-dca05.sh - Overwrite installed config (e.g.: from prod or uat)
#
# This is used when testing the config packages from prod and uat. It
# grabs the few files needed to get OpenXPKI started while leaving the
# rest as-is. It uses the head of the current branch as the reference
# commit.
#
# As an optional argument, a tree-ish may be specified t determine what
# state should be used by "git archive  ..."

# safety net - someday, I'm going to accidently run this on my mac
# rather than in the dca05 vm instance. This little test should
# save my tail...
host=`hostname`
if [ "$host" != "dca05" ]; then
    echo "ERROR - not on dca05, aborting."
    exit 1
fi

# reference commit
if [ -z "$1" ]; then
    commit=HEAD
else
    commit="$1"
fi

files="files/etc/openxpki/instances/level2/config.xml \
    files/etc/openxpki/instances/level2/token.xml \
    files/etc/openxpki/instances/level2/serverca/auth.xml \
    files/etc/openxpki/instances/level2/serverca/ldappublic.xml \
    files/etc/openxpki/instances/level2/serverca/profile.xml \
    files/etc/openxpki/instances/level2/userca/auth.xml \
    files/etc/openxpki/instances/level2/userca/ldappublic.xml \
    files/etc/openxpki/instances/level2/userca/profile.xml \
    files/etc/openxpki/instances/level2/userca/workflow_activity_smartcard_pin_unblock.xml \
    files/etc/openxpki/policy.pm \
    files/etc/sysconfig/openxpki.local"

#tar -cf - -C files $files | sudo tar -xf -C /
git archive "$commit" $files | sudo tar -xvf - -C / --strip-components 1
sudo chmod g-w /etc

