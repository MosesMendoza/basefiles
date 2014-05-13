#!/bin/bash

#############################################################
# This script calls cl-support if it finds
# any core files under the path passed as argument
# to the script.
# 
# This script is invoked by monit on timestamp changes
# to the /var/support/core dir. This script maybe called
# more than once when the core file is being written to 
# under /var/support/core. The script invokes cl-support
# only when there are *.core.xz files available
#
#############################################################

if [ $# -ne 1 ]; then
	echo "usage: $0 <path to coredir>"
	exit 1
fi

coredir_path=$1

ls ${coredir_path}/*.core 2>&1 > /dev/null
if [ $? -eq 0 ]; then 
	/usr/cumulus/bin/cl-support "found core file(s): `ls -1 ${coredir_path}/*.core`"
fi



