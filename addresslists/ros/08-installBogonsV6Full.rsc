###
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

/system script add name="FetchBogonsV6Full" source={

# Make global variables available within the local scope
:global AddressListsWebRemotePassword
:global AddressListsWebRemoteUser
:global AddressListsWebRemoteHost

:if (:typeof[$AddressListsWebRemoteUser] = "nil") do={
    # If no username was defined assume that authentication isn't required
    /tool fetch url="https://$AddressListsWebRemoteHost/bogons-v6-full.rsc" mode=https;
    } else={
    # If a username was set assume authentication is mandatory and also use a password
    /tool fetch url="https://$AddressListsWebRemoteUser:$AddressListsWebRemotePassword@$AddressListsWebRemoteHost/bogons-v6-full.rsc" mode=https;
}

}

/system script add name="ReplaceBogonsV6Full" source={

# Declare list name including its extension (has to be .rsc)
:local listName "bogons-v6-full.rsc";

# Declare comment used to identify all existing entries of this list
:local listComment "bogons-v6-full";

# Check if the list file is present
:if ([:len [/file find name="$listName"]] > 0) do={

	# If present, verify that the list file is at least 1KB in size
	:if ( [/file get [/file find name=$listName] size] > 1000 ) do={
        :log info "$listName: Removing existing entries";

			# Identify all pre-existing entries and remove them
   	        :foreach entry in=[/ip firewall address-list find] do={
    	    :if ( [/ipv6 firewall address-list get $entry comment] = "$listComment" ) do={
    	        /ipv6 firewall address-list remove $entry;
    	        }
    	    }

			# Import new entries from list file
	        :log info "$listName: Importing new entries";
   	        /import file-name=$listName;
            :delay 5
			
            # Finally the local copy is removed in order to minimize the number
			# of write cycles to the local flash memory. Existing entries
			# will only be rewritten if a list file is present which may
			# only happen if a list file was fetched from the web server
			# or uploaded manually e.g. via ssh
   	        /file remove $listName;

	    } else={

		# Log a warning if the list file exists but is smaller than 1KB in size
	    :log warning "WARNING: $listName is < 1KB. Not attempting to replace existing entries.";
        }
	} else={

	# Log a warning if the list file isn't present and don't attempt to remove or replace any existing entries
	:log warning "WARNING: File $listName doesn't exist - keeping existing entries! If this happens unexpectedly verify that the remote server is reachable";
    }
}

# Create scheduler entries
/system scheduler add interval=1d name="FetchBogonsV6Full" on-event="/system script run FetchBogonsV6Full" start-date=jan/01/1970 start-time=01:45:00
/system scheduler add interval=1d name="ReplaceBogonsV6Full" on-event="/system script run ReplaceBogonsV6Full" start-date=jan/01/1970 start-time=01:55:00

# Fetch and install address list
:put ">>> Fetching list ..."
/system script run FetchBogonsV6Full;
:delay 5;
:put ">>> Installing entries ..."
/system script run ReplaceBogonsV6Full;
