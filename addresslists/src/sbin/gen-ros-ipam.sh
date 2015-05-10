#!/bin/sh

#### FUNCTIONS

source ./gen-ros-include.sh

##### SCRIPT BODY

if [ -d ${DEST_DIR} ] ; then

    scriptStart
    scriptLog "Updating address lists"

  LIST_SQL_SUBNETS="$(/opt/ona/bin/dcm.pl -r ona_sql sql=/opt/ona/sql/ros_fetch_subnets.sql | awk 'NR>1')"
  LIST_SQL_HOSTS="$(/opt/ona/bin/dcm.pl -r ona_sql sql=/opt/ona/sql/ros_fetch_hosts.sql | awk 'NR>1')"
  LIST_SQL_NETBLOCKS="$(/opt/ona/bin/dcm.pl -r ona_sql sql=/opt/ona/sql/ros_fetch_netblocks.sql | awk 'NR>1')"
  
  export LISTNAME="ipamGlobalAddressList"
  if [ -n "${LIST_SQL_SUBNETS}" ] && [ -n "${LIST_SQL_HOSTS}" ] && [ -n "${LIST_SQL_NETBLOCKS}" ]
    then
      test -f ${DEST_DIR}/${LISTNAME}.rsc && rm ${DEST_DIR}/${LISTNAME}.rsc;
      echo "# -------------------------------------------------------" >> ${DEST_DIR}/${LISTNAME}.rsc;
      insertAuthorDetails
      insertListDetails
      echo "/ip firewall address-list" >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_SQL_SUBNETS}" | awk -F ':' '{print "add list=" $1 " address=" $2 " comment=IPAM"}' >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_SQL_HOSTS}" | awk -F ':' '{print "add list=" $1 " address=" $2 " comment=IPAM"}' >> ${DEST_DIR}/${LISTNAME}.rsc;
      echo "${LIST_SQL_NETBLOCKS}" | awk -F ':' '{print "add list=" $1 " address=" $2 " comment=IPAM"}' >> ${DEST_DIR}/${LISTNAME}.rsc;
    else
      errNotify
  fi;

fi;

exit 0;
