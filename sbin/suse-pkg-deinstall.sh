#!/bin/sh
#
# suse-pkg-deinstall.sh - deinstall custom-built OpenXPKI rpm dependencies

rpm -qa --queryformat='%{NAME} %{BUILDHOST}\n' | \
    grep dca05.de.db.com | \
    awk '{print $1}' | sudo rpm -e
