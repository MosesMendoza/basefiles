#!/bin/bash

/usr/sbin/switchd -lic /etc/cumulus/.license.txt 2>/dev/null >/dev/null
if [ $? -eq 1 ]; then
    echo >&2
    echo >&2
    echo '*****************************************************************' >&2
    echo 'This installation of Cumulus Linux is not licensed.  The front' >&2
    echo 'panel ports will not operate.  To obtain a license, contact' >&2
    echo 'Cumulus Networks: http://cumulusnetworks.com/' >&2
    echo '*****************************************************************' >&2
    echo >&2
    echo >&2
fi
