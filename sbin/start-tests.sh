#!/bin/sh 
#

#tests="/usr/local/lib/site_perl/t/60_workflow/45_activity_tools.t"
#tests="/usr/local/lib/site_perl/t/60_workflow/32_smartcard_cardadm.t"
tests="/etc/openxpki/local/lib/t/60_workflow/32_smartcard_cardadm.t"
perl -I/etc/openxpki/local/lib -I/usr/local/lib/site_perl $tests
