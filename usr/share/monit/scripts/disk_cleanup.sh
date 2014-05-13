#!/bin/bash

/usr/share/monit/scripts/support_cleanup.py

/usr/sbin/logrotate /etc/logrotate.conf
