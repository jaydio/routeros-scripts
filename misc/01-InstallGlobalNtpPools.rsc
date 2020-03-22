###
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

## This script is partially based on examples found here:
## http://wiki.mikrotik.com/wiki/Manual:Scripting-examples#Allow_use_of_ntp.org_pool_service_for_ntp

# Set primary and secondary ntp servers to be fetched from
# pool.ntp.org. This automatically ensures that ntp servers
# are installed that are located within the geographical region
# of the router
/system script add name="SetGlobalNtpServers" source={
:global SystemNtpPrimary "0.pool.ntp.org";
:global SystemNtpSecondary "1.pool.ntp.org";
}

# Create scheduler to execute script at boot time
/system scheduler add name="SetGlobalNtpServers" on-event="/system script run SetGlobalNtpServers" start-time=startup

# Define script to configure ntp servers
/system script add name="ConfigureGlobalNtpServers" source={

# Make global variables available within the local scope
:global SystemNtpPrimary
:global SystemNtpSecondary

# Resolve the first ip address of each pool
:local NtpIpPrimary [:resolve $SystemNtpPrimary];
:local NtpIpSecondary [:resolve $SystemNtpSecondary];

# Store the currently configured ip addresses
:local NtpCurPrimary [/system ntp client get primary-ntp];
:local NtpCurSecondary [/system ntp client get secondary-ntp];

# Debug output
:put ("Primary (old): " . $NtpCurPrimary . " Primary (New): " . $NtpIpPrimary);
:put ("Secondary (old): " . $NtpCurSecondary . " Secondary (New): " . $NtpIpSecondary);

# Change primary if required
:if ($NtpIpPrimary != $NtpCurPrimary) do={
    :put "Changed address of primary ntp server";
    /system ntp client set primary-ntp="$NtpIpPrimary";
    }

# Change secondary if required
:if ($NtpIpSecondary != $NtpCurSecondary) do={
    :put "Changed address of secondary ntp server";
    /system ntp client set secondary-ntp="$NtpIpSecondary";
    }
}

# On a daily basis fetch and install most recent ntp servers from given pools
/system scheduler add interval=1d name="ConfigureGlobalNtpServers" on-event="/system script run ConfigureGlobalNtpServers" start-date=jan/01/1970 start-time=03:00:00

# After successful installation

# Declare global ntp servers (avoids reboot)
/system script run SetGlobalNtpServers

# Implement configuration
/system script run ConfigureGlobalNtpServers

# Make sure ntp client is enabled
:system ntp client set enabled=yes

# Make globally declared ntp servers available within local scope
:global SystemNtpPrimary
:global SystemNtpSecondary

:put "The following ntp pools are configured on this system:"
:put "---------------------------------------------------"
:put "Primary -> $SystemNtpPrimary"
:put "Secondary -> $SystemNtpSecondary"
:put "---------------------------------------------------"


