#!/bin/sh
#
# gen-ros-blacklists.sh - generate black list files for direct import
# Copyright (C) 2015-2020 - Dennis J. "JD" Bungart <jd@route1.ph>
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

#### FUNCTIONS

source /usr/local/sbin/gen-ros-include.sh

##### SCRIPT BODY

if [ -d ${DEST_DIR} ] ; then

    scriptStart
    scriptLog "Updating address lists"

##### BLACKLIST: dshield

  export LISTNAME="dshield"
  LIST_WGET="$(wget ${WGET_ARGS_EXTRA} -q -O - http://feeds.dshield.org/block.txt)"
  if [ -n "${LIST_WGET}" ]
    then
      test -f ${DEST_DIR}/${LISTNAME}.rsc && rm ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertAuthorDetails
      echo "# Address details courtesy of https://www.dshield.org/" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# (c) DShield.org - SANS Internet Storm Center" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# This list summarizes the top 20 attacking class C (/24)" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# subnets over the last THREE DAYS. The number of 'attacks'" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# indicates the number of targets reporting scans from this" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# subnet" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertListDetails
      echo "/ip firewall address-list" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_WGET}" | awk --posix '/^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0\t/ { print "add list=blacklist address=" $1 "/24 timeout=\"1w 00:00:00\" comment=DShield";}' >> ${DEST_DIR}/${LISTNAME}.rsc;
    else
      errNotify
  fi;

##### BLACKLIST: spamhaus
  
  export LISTNAME="spamhaus"
  LIST_WGET="$(wget ${WGET_ARGS_EXTRA} -q -O - http://www.spamhaus.org/drop/drop.lasso)"
  if [ -n "${LIST_WGET}" ]
    then
      test -f ${DEST_DIR}/${LISTNAME}.rsc && rm ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertAuthorDetails
      echo "# Address details courtesy of https://www.spamhaus.org/drop/" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# (c) Spamhaus Project - Non-Profit Anti-spam DNS/IP blacklisting" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# DROP (Don't Route Or Peer) is an advisory \"drop all traffic\"" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# list. DROP is a tiny subset of the SBL designed for use by" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# firewalls and routing equipment. The DROP list will not" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# includes any IP space allocated to a legitimate network" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# and reassigned - even if reassigned to the proverbial" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# \"spammers from hell\"" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertListDetails
      echo "/ip firewall address-list" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_WGET}" | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "add list=blacklist address=" $1 " timeout=\"1w 00:00:00\" comment=SpamHaus";}' >> ${DEST_DIR}/${LISTNAME}.rsc
    else
      errNotify
  fi;

##### BLACKLIST: bogons-v4
  
  export LISTNAME="bogons-v4"
  LIST_WGET="$(wget ${WGET_ARGS_EXTRA} -q -O - http://www.team-cymru.org/Services/Bogons/bogon-bn-nonagg.txt)"
  if [ -n "${LIST_WGET}" ]
    then
      test -f ${DEST_DIR}/${LISTNAME}.rsc && rm ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertAuthorDetails
      echo "# Address details courtesy of http://www.team-cymru.org" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# (c) Team Cymru Research NFP - making the Internet more secure" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# This is the list of bit notation bogons, unaggregated." >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# Updated as IANA allocations and special prefix reservations" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# are made." >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertListDetails
      echo "/ip firewall address-list" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_WGET}" | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "add list=bogons address=" $1 " timeout=\"1w 00:00:00\" comment=bogons-v4";}' >> ${DEST_DIR}/${LISTNAME}.rsc
    else
      errNotify
  fi;

##### BLACKLIST: bogons-v4-full
  
  export LISTNAME="bogons-v4-full"
  LIST_WGET="$(wget ${WGET_ARGS_EXTRA} -q -O - http://www.team-cymru.org/Services/Bogons/fullbogons-ipv4.txt)"
  if [ -n "${LIST_WGET}" ]
    then
      test -f ${DEST_DIR}/${LISTNAME}.rsc && rm ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertAuthorDetails
      echo "# Address details courtesy of http://www.team-cymru.org" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# (c) Team Cymru Research NFP - making the Internet more secure" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# Fullbogons are a larger set which also includes IP space" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# that has been allocated to an RIR, but not assigned by that RIR" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# to an actual ISP or other end-user. IANA maintains a convenient" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# IPv4 summary page listing allocated and reserved netblocks," >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# and each RIR maintains a list of all prefixes that they have" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# assigned to end-users." >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertListDetails
      echo "/ip firewall address-list" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_WGET}" | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\// { print "add list=bogons address=" $1 " timeout=\"1w 00:00:00\" comment=bogons-v4-full";}' >> ${DEST_DIR}/${LISTNAME}.rsc
    else
      errNotify
  fi;

##### BLACKLIST: bogons-v6-full
  
  export LISTNAME="bogons-v6-full"
  LIST_WGET="$(wget ${WGET_ARGS_EXTRA} -q -O - http://www.team-cymru.org/Services/Bogons/fullbogons-ipv6.txt)"
  if [ -n "${LIST_WGET}" ]
    then
      test -f ${DEST_DIR}/${LISTNAME}.rsc && rm ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertAuthorDetails
      echo "# Address details courtesy of http://www.team-cymru.org" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# (c) Team Cymru Research NFP - making the Internet more secure" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# Fullbogons are a larger set which also includes IP space" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# that has been allocated to an RIR, but not assigned by that RIR" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# to an actual ISP or other end-user. IANA maintains a convenient" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# IPv4 summary page listing allocated and reserved netblocks," >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# and each RIR maintains a list of all prefixes that they have" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# assigned to end-users." >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertListDetails
      echo "/ipv6 firewall address-list" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_WGET}" | awk --posix '/(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/ {print "add list=bogons address=" $1 " timeout=\"1w 00:00:00\" comment=bogons-v6-full";}' >> ${DEST_DIR}/${LISTNAME}.rsc
    else
      errNotify
  fi;

##### BLACKLIST: tornodes-v4
  
  export LISTNAME="tornodes-v4"
  LIST_WGET="$(wget ${WGET_ARGS_EXTRA} -q -O - https://www.dan.me.uk/torlist/)"
  if [ -n "${LIST_WGET}" ]
    then
      test -f ${DEST_DIR}/${LISTNAME}.rsc && rm ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertAuthorDetails
      echo "# Courtesy of (c) Daniel Austin MBCS" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# https://www.dan.me.uk/tornodes" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# Contains a list of all nodes in the TOR network" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertListDetails
      echo "/ip firewall address-list" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_WGET}" | awk --posix '/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/ { print "add list=tornodes address=" $1 " timeout=\"1w 00:00:00\" comment=tornodes";}' >> ${DEST_DIR}/${LISTNAME}.rsc
  else
      errNotify
  fi;

##### BLACKLIST: tornodes-v6
  
  export LISTNAME="tornodes-v6"
  LIST_WGET="$(wget ${WGET_ARGS_EXTRA} -q -O - https://www.dan.me.uk/torlist/)"
  if [ -n "${LIST_WGET}" ]
    then
      test -f ${DEST_DIR}/${LISTNAME}.rsc && rm ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertAuthorDetails
      echo "# Courtesy of (c) Daniel Austin MBCS" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# https://www.dan.me.uk/tornodes" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# Contains a list of all nodes in the TOR network" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertListDetails
      echo "/ip firewall address-list" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_WGET}" | awk --posix '/(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/ {print "add list=bogons address=" $1 " timeout=\"1w 00:00:00\" comment=tornodes-v6";}' >> ${DEST_DIR}/${LISTNAME}.rsc
  else
      errNotify
  fi;

fi;

exit 0;
