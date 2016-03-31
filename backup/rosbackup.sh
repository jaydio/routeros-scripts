#!/bin/bash
#
# rosbackup.sh - simple back up of multiple RouterOS instances via SSH
# Copyright (C) 2015 - Jan Dennis Bungart <me@jayd.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

# export user to use when establishing ssh connections
export SSHUSER="backup"

# define connection parameters such as the path to a private key
export SSHARGS="-i ~/.ssh/id_rsa_rosbackup \
                -F /dev/null \
                -oConnectTimeout=10 \
                -oBatchMode=yes \
                -oControlMaster=auto \
                -oControlPersist=1h \
                -oControlPath=~/.ssh/ssh-rosbackup-%r-%h-%p                     
                -oPubkeyAcceptedKeyTypes=+ssh-dss
                -oControlPath=~/.ssh/ssh-%r-%h-%p"

# define the parent path for backups (defaults to user's home directory)
# hint: omit the trailing slash
#export BACKUPPATH_PARENT="/mnt/backups/ros"
export BACKUPPATH_PARENT="."

# Specify the password required for restoring backup files (.backup)                
export BACKUPPASSWORD="FIXMEFOOBAR"

# an array of router ip addresses, extend as needed
ROUTERS=()
ROUTERS+=("192.168.200.1");
#ROUTERS+=("192.168.200.2");
#ROUTERS+=("192.168.200.3");

# or a range of addresses
#ROUTERS+=($(seq -f "192.168.200.%g" 1 254));

# functions
function sanitizeRosOutput() {
# strip output from newlines and CR/LF
awk 'NR>1{$1=$1}{ print $2 }' | sed 's/\r$//'
}

# iteration
for ROUTERADDRESS in ${ROUTERS[@]}; do

    # check if we can authenticate with the remote host trying to execute a command, if not continue with next host
    echo "Trying ${ROUTERADDRESS} ... "
    ssh -q ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "system identity print" > /dev/null || continue
    
	# generate an individual timestamp per router
	TIMESTAMP="$(date +%m%d%y%H%M)";

	# fetch the router's identity 
	ROUTERNAME="$(ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "system identity print" | sanitizeRosOutput)";

	# fetch RouterOS version
	ROUTEROSVERSION="$(ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "system resource print" | grep version | sanitizeRosOutput)";

	# fetch the board's architecture
	ROUTERARCH="$(ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "system resource print" | grep architecture-name | sanitizeRosOutput)";

	# define the backup name
	BACKUPNAME="${ROUTERNAME}-${ROUTERADDRESS}-ros${ROUTEROSVERSION}-${ROUTERARCH}-${TIMESTAMP}";

	# define the local path for backups
	BACKUPPATH="${BACKUPPATH_PARENT}/${ROUTERNAME}-${ROUTERADDRESS}-ros${ROUTEROSVERSION}-${ROUTERARCH}";

	# check if directory for router already exists, if not create one
	test -d ${BACKUPPATH} || mkdir ${BACKUPPATH}

	# inform about which router is currently being backed up and provide some details
	echo ">>>> Starting backup of ${ROUTERNAME} ($ROUTERADDRESS) running RouterOS version ${ROUTEROSVERSION} (${ROUTERARCH}) .."

	# save system information to local info file
	ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "system identity print" >> ${BACKUPPATH}/${BACKUPNAME}.INFO.txt;
	ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "system routerboard print" >> ${BACKUPPATH}/${BACKUPNAME}.INFO.txt;
	ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "system resource print" >> ${BACKUPPATH}/${BACKUPNAME}.INFO.txt;

	# create a binary backup that can be used for immediate restore.
	# restore only works on a similar rb model e.g. with the same architecture
	ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "system backup save name=\"${BACKUPNAME}\" password=\"${BACKUPPASSWORD}\"";
	scp ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS}:${BACKUPNAME}.backup ${BACKUPPATH}/;
	# give the flashrom a few seconds to breath
	sleep 5;
	ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "file remove \"${BACKUPNAME}.backup\"";

	# create a script based backup for restore. this works on any router
	# but might require slight adjustments of the script when changing platforms
	ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "export file=\"${BACKUPNAME}\"";
	scp ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS}:${BACKUPNAME}.rsc ${BACKUPPATH}/;
	# give the flashrom a few seconds to breath
	sleep 5;
	ssh ${SSHARGS} ${SSHUSER}@${ROUTERADDRESS} "file remove \"${BACKUPNAME}.rsc\"";

done
