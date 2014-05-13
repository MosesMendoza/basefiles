#! /bin/bash
#-------------------------------------------------------------------------------
#
# Copyright 2012 Cumulus Networks, inc.
#
#-------------------------------------------------------------------------------
# Forcing switchd restart
# This script should be called as a get-out-of-jail card only

/usr/cumulus/bin/cl-support -e switchd.debug,switchd.stack,system,network.kernel "switchd heartbeat miss"

service switchd restart

exit 0
