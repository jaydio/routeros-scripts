/system script add name="FetchIpamGlobalAddressList" source={

# Make global variables available within the local scope
:global AddressListsWebRemotePassword
:global AddressListsWebRemoteUser
:global AddressListsWebRemoteHost

:if (:typeof[$AddressListsWebRemoteUser] = "nil") do={
    # If no username was defined assume that authentication isn't required
    /tool fetch url="https://$AddressListsWebRemoteHost/ipamGlobalAddressList.rsc" mode=https;
    } else={
    # If a username was set assume authentication is mandatory and also use a password
    /tool fetch url="https://$AddressListsWebRemoteUser:$AddressListsWebRemotePassword@$AddressListsWebRemoteHost/ipamGlobalAddressList.rsc" mode=https;
}

}

/system script add name="ipamGlobalAddressList" source={

# Declare list name including its extension (has to be .rsc)
:local listName "ipamGlobalAddressList.rsc";

# Declare comment used to identify all existing entries of this list
:local listComment "IPAM";

# Check if the list file is present
:if ([:len [/file find name="$listName"]] > 0) do={

	# If present, verify that the list file is at least 1KB in size
	:if ( [/file get [/file find name=$listName] size] > 1000 ) do={
        :log info "$listName: Removing existing entries";

			# Identify all pre-existing entries and remove them
   	        :foreach entry in=[/ip firewall address-list find] do={
    	    :if ( [/ip firewall address-list get $entry comment] = "$listComment" ) do={
    	        /ip firewall address-list remove $entry;
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
/system scheduler add interval=1d name="FetchIpamGlobalAddressList" on-event="/system script run FetchIpamGlobalAddressList" start-date=jan/01/1970 start-time=01:41:00
/system scheduler add interval=1d name="ReplaceIpamGlobalAddressList" on-event="/system script run ReplaceIpamGlobalAddressList" start-date=jan/01/1970 start-time=01:51:00

# Fetch and install address list
:put ">>> Fetching list ..."
/system script run FetchIpamGlobalAddressList;
:delay 5;
:put ">>> Installing entries ..."
/system script run ReplaceIpamGlobalAddressList;
