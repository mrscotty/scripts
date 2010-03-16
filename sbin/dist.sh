#!/bin/sh
#
# Copy files that must land in the distro directories


xmldir=instances/trustcenter1
for i in $xmldir/config.xml $xmldir/acl.xml $xmldir/workflow.xml $xmldir/workflow_condition.xml; do
	dest=`dirname $i`
	if [ ! -f /etc/openxpki/$i.orig ]; then
		echo "Saving orig version of $i"
		cp -p /etc/openxpki/$i /etc/openxpki/$i.orig
	fi
	echo "Copying $i"
	cp -p $i /etc/openxpki/$dest/
done
