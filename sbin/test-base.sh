#!/bin/sh


(cd ~/openxpki/trunk/perl-modules/core/trunk && TEST_FILES="t/12*/*.t" make -e test)
