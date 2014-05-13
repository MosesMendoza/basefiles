#! /bin/bash
#-------------------------------------------------------------------------------
#
# Copyright 2012 Cumulus Networks, inc.
#
#-------------------------------------------------------------------------------
#
# check to see if there has been any Supervisor generated frame transmission
#
# we use the fact that all Supervisor generated frames are enqueued with
# cos/priority of 3, and we count these frames.
#
# this script should not be called any faster that the slowest expected
# transmit interval (>30s if lldpd is running).
#

run_dir=/var/run
lock_file=$run_dir/.sup_tx_check.lock

exec 9>$lock_file
if ! flock -e -n 9 ; then
	echo "Another instance of this program is already running"
	exit 0
fi

# make sure that switchd is running
#
[ ! -r /var/run/switchd.pid ] && exit 0

switchd_pid=$(pidof switchd)
[ -z $switchd_pid ] && exit 0

[ x"$switchd_pid" != x"$(cat /var/run/switchd.pid)" ] && exit 0

# make sure the configuration is correct
#
CNT_CONFIG=$(/usr/lib/cumulus/bcmcmd getreg raw TX_CNT_CONFIG[0] | /bin/sed -e "s/^.*=//")
[ -z $CNT_CONFIG ] && exit 0

let CNT_CONFIG=$CNT_CONFIG
if [ $CNT_CONFIG -eq 0 ]
then
    /usr/lib/cumulus/bcmcmd setreg TX_CNT_CONFIG[0] TYPE=0 COS_PRI=3 SRC_PORT=0
    echo "$0: configuring the ASIC" > /dev/stderr
    exit 0
fi	

# make sure that we have some up interfaces
#
NUM_UP=$(/sbin/ip --oneline link show up | /bin/grep swp | /bin/grep LOWER_UP | /usr/bin/wc -l)
if [ $NUM_UP -eq 0 ]
then
    # can't transmit if there aren't any up interfaces
    #
    exit 0
fi

# make sure that we should be sending frames from the sup
#
# - lldpd is a good indicator of this
# - note that at least one entry will exist in ps... our grep call
#
LLDP_RUNNING=$(/bin/ps aux | /bin/grep lldpd | /usr/bin/wc -l)
if [ $LLDP_RUNNING -eq 1 ]
then
    # no clear generator of outgoing transmit frames
    #
    exit 0
fi

# check the counters
#
let CPU_PKTS=$(/usr/lib/cumulus/bcmcmd getreg raw TX_PKT_CNT[0] | /bin/sed -e "s/^.*=//")
if [ $CPU_PKTS -eq 0 ]
then
    echo "$0: no CPU egress packets since last checked" > /dev/stderr
    exit 1
fi

# clear the CPU egress packet counter for the next time
#
/usr/lib/cumulus/bcmcmd setreg TX_PKT_CNT[0] 0
exit 0

