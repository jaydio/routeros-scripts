#!/bin/sh
#
# gen-ros-include.sh.sh - functional include file for address list generation
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

export DEST_DIR="/var/www/html/lists.mikrotik.help";
export SRC_URL="https://lists.mikrotik.help";
export LOGFILE="/var/log/generate-addresslists.log";
export LOCKFILE="/var/lock/subsys/$(basename $0)_run";
export WEBLOGFILE="${DEST_DIR}/update.log";
export LASTSYNCFILE="${DEST_DIR}/timestamp.txt";
export DATE_CUR_UTC=$(date -u);
export WGET_ARGS_EXTRA="--max-redirect 0 --timeout=10 --dns-timeout=5 --connect-timeout=5"

trap errNotify ERR;
trap scriptExit EXIT;

function errNotify() {
if [ $? != "0" ]; then
        scriptLog "${LISTNAME}: UPDATE FAILED!!"
fi
}

function insertAuthorDetails() {
echo "# Automatically genereted address list for RouterOS" >> ${DEST_DIR}/${LISTNAME}.rsc;
echo "# Powered by: John Doe / john@doe.com" >> ${DEST_DIR}/${LISTNAME}.rsc;
echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
}

function insertListDetails() {
echo "# Generated on: ${DATE_CUR_UTC}" >> ${DEST_DIR}/${LISTNAME}.rsc;
echo "# Format: MikroTik RouterOS script" >> ${DEST_DIR}/${LISTNAME}.rsc;
echo "# Usage: import ${LISTNAME}.rsc" >> ${DEST_DIR}/${LISTNAME}.rsc;
echo "# Source: ${SRC_URL}" >> ${DEST_DIR}/${LISTNAME}.rsc;
echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
}

function scriptLog() {
# Append to a continious log file while writing to a separate
# session based log placed within the root path of the mirror.
# It will get overwritten with every run. This way users
# have the chance to check for possible errors that might
# have occured during the last update run.
echo "$(date -u) $(basename $0); $1" | tee -a ${LOGFILE} ${WEBLOGFILE};
}

function suspendAccess() {
cat <<'HERE' > ${DEST_DIR}/.htaccess
ErrorDocument 403 'One or more address lists in this folder are currently being <b>updated</b>! <br/><br/>In order to prevent your network gear from fetching an empty or inconsistent address list<br/> we have temporarily disabled access. The service will resume once all lists were generated. <br/>Please try again in a short while. Consider <b>contacting</b> the local <b>hostmaster</b> <br/>in case this <b>message</b> keeps on <b>showing for at least 5 more minutes</b>.'

<IfModule mod_authz_core.c>
    # Apache 2.4 >
    Require all denied
</IfModule>
<IfModule !mod_authz_core.c>
    # Apache 2.2
    Order allow,deny
    Deny from all
</IfModule>
HERE
}

function restoreAccess() {
rm -f > ${DEST_DIR}/.htaccess
}

function scriptStart() {
scriptLog "Removing weblog of previous run.."
rm ${WEBLOGFILE}
scriptLog "---- $(date -u) - $(basename $0) ----"
scriptLog "Address lists are now being generated;"
suspendAccess
scriptLog "Suspending repository access"

if [ -f ${LOCKFILE} ]; then
    scriptLog "Lock file detected - aborting!"
    exit 2
else
    scriptLog "Creating lock file.."
    touch ${LOCKFILE}
fi
}

function scriptExit() {
scriptLog "All address lists have been updated successfully!"
scriptLog "Automated removal of lock file"
/bin/rm -f ${LOCKFILE}

scriptLog "Placing timestamp"
echo -e "Last synchronization: \n\n$(date) \n$(date -u)" > ${LASTSYNCFILE}


scriptLog "---- $(date -u) - $(basename $0) ----"
}
