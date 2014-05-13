#!/bin/bash

if [ -n "`ls /var/support/cl_support*.tar.xz 2>/dev/null`" ]; then
    echo >&2
    echo >&2
    echo '*****************************************************************' >&2
    echo 'Please send these support file(s) to support@cumulusnetworks.com:' >&2
    for cs in /var/support/cl_support*.tar.xz; do
        echo '' $cs >&2
    done
    echo '*****************************************************************' >&2
    echo >&2
    echo >&2
fi
