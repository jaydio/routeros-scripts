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

# Create script for setting up global variables
/system script add name="SetGlobalVarsAddressLists" source={
:global AddressListsWebRemoteHost "<AddressListsWebRemoteHost>"
:global AddressListsWebRemoteUser "<AddressListsWebRemoteUser>"
:global AddressListsWebRemotePassword "<AddressListsWebRemotePassword>"
}

# Create scheduler to execute script at boot time
/system scheduler add name="SetGlobalVarsAddressLists" on-event="/system script run SetGlobalVarsAddressLists" start-time=startup

# After installation, execute the script to declare variables (avoids reboot)
/system script run SetGlobalVarsAddressLists

# Print out variables on the CLI for verification
:global AddressListsWebRemoteHost
:global AddressListsWebRemoteUser
:global AddressListsWebRemotePassword

:put "The following global variables have been configured:"
:put "---------------------------------------------------"
:put "AddressListsWebRemoteHost -> $AddressListsWebRemoteHost"
:put "AddressListsWebRemoteUser -> $AddressListsWebRemoteUser"
:put "AddressListsWebRemotePassword -> $AddressListsWebRemotePassword"
:put "---------------------------------------------------"

