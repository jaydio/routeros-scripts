# Automated deployment of address lists

In larger deployments it can be time saving to synchronize address lists across multiple routers.

The following approach uses a central web server being firewall friendly. Furthermore it can provide for extra security using basic authentication via SSL/TLS.

## Dynamic Address List entries (Blacklists only)

To reduce the amount of write cycles made to the flash memory (NAND) all address list entries of blacklists are stored in memory. By default the **timeout** value for blacklist entries is set to **one week**. This ensures that whenever the list server is unreachable (for whatever reason) that the last set of blacklist entries will remain in place for at least one week providing basic protection.

However, due to their volatile nature, blacklist entries will not **survive a reboot**. Make sure to **execute the fetch and replace scripts after a reboot**. Alternatively you may of course create respective scheduler entries to automate this task upon reboot. As of April 2017 such entries are not included in this collection as there are situations were it might not be desirable to kick off an import upon boot.

Kudos to Dmitry <amokk42@gmail.com> and Dave Joyce from Intrus Technologies for the inspiration.

References:

 * https://forum.mikrotik.com/viewtopic.php?f=9&t=98804

## Address List Categories

 * Public blacklists (PE, provider edge)
 * Internal blacklists (P, provider core)
 * IPAM export (P+PE, provider core & edge)

## Implementation of Address Lists within RouterOS

 * Single ip address (e.g. 10.99.99.1)
 * Subnet using the CIDR notation (e.g. 10.99.99.0/24)
 * Range of ip addresses (e.g. 10.99.99.100-10.99.99.200)

See [Manual:IP/Firewall/Address list](http://wiki.mikrotik.com/wiki/Manual:IP/Firewall/Address_list) for further details.

## Build Scripts and Export from IPAM

An IP address management export can be taken from any ip address management solution (IPAM) including - but not limited to - [OpenNetAdmin](http://opennetadmin.com/), [NOC](https://kb.nocproject.org/) and [NIPAP](http://spritelink.github.io/NIPAP/). An export would usually contain either a subset or all internal subnets, hosts and netblocks. If you're Interested in the build scripts and documentation on how to export from OpenNetAdmin have a look at the [src/](src/.) directory.

## Words of Warning

The documented approach is fairly fragile. Having said that, all scripts are provided as-is and come without any warranty to be fit for a particular purpose. Use them with caution!

The available router scripts (`.rsc`) have been tested in production at our university network without having caused any trouble. It's only fair to note that almost all of our university routers are located in walking distance and are connected using an out-of-band management domain which drastically reduces the possible the time needed to restore a system. I recommend to take pre-measures incl. non-alias based firewall rules to allow administrative access.

All address lists scripts as found in [ros/](ros/) follow this workflow ..

 * Installing a new address list involves the following steps
   * Check if the address list file is present on the router's file system
   * If present, remove all pre-existing entries identified by address list specific comment (e.g. "IPAM", "OpenBL" or "DShield")
   * Once removed, attempt to import the address list file from the local file system
   * If the import succeeds, and only then, purge the address list file from the local file system
   * If the address list file is missing for whatever reason, the replace script exits with a warning without removing any entries
   * If the address list file is smaller than 1KB (Kilobyte) it will not be used

Conditions you need to be aware of also include ..

 * The fetch script has no way to determine if ..
   * .. the list on the remote server contains newer entries than those currently installed
   * .. the address list file contains any errors (e.g. file was truncated on the remote server or during transfer)
 * Fetching a broken address list file WILL cause trouble. Be mindful on how to apply the supplied scripts especially on high-latency links.

## Address Mappings

Sample address list exported from IPAM:

```
/ip firewall address-list
add list=HOST-SERVERNET.host01.example.com address=10.10.0.2 comment=IPAM
add list=HOST-SERVERNET.host01.example.com address=10.10.0.3 comment=IPAM
add list=NETBLOCK-BRANCH2 address=10.250.10.0-10.250.20.255 comment=IPAM
add list=SUBNET-SERVERNET address=10.10.10.0/24 comment=IPAM
```

Netblocks can be mapped using a range of ip addresses, subnets using the more common CIDR notation and hosts by using their respective ip address(es). If a host is configured with more than one ip address within the same network, the interface name or subnet name can be appended to the respective list name.

## Installation Scripts

### Global Variables

All router scripts used to install a certain address list can be found in [ros/](ros/). Each one automatically takes care of installing a set of scripts and scheduler entries to ensure automated updates. If you don't like the default scheduler settings simply change the respective intervals before or after the script was uploaded. Since all scripts are based on global variables declared by the `00-SetGlobalVarsAddressLists` script you'll have to modify and upload it first prior to any address list related scripts.

The following global variables are declared within 00-SetGlobalVarsAddressLists.rsc:

 * AddressListsWebRemoteHost
 * AddressListsWebRemoteUser
 * AddressListsWebRemotePassword

Usually it is advisable to install password protection (basic authentication) on the web server serving the address lists. Especially when address lists are generated using sensitive information from IPAM. However, when using a public service such as [lists.mikrotik.help](https://lists.mikrotik.help) access is usually not password protected. In case authentication is not required, make sure to set an empty values for the variable `AddressListsWebRemoteUser`.

### Installation Workflow

The following workflow gets you started using the public blacklist service reachable through [lists.mikrotik.help](http://lists.mikrotik.help/). The provided address lists are being updated hourly.

```
$ cd Desktop/
$ git clone https://github.com/jaydio/routeros-scripts
$ cd routeros-scripts/addresslists/ros
$ sed -i -e "s,<AddressListsWebRemoteHost>,lists.mikrotik.help,g" 00-SetGlobalVarsAddressLists.rsc
$ sed -i -e "s,<AddressListsWebRemoteUser>,,g" 00-SetGlobalVarsAddressLists.rsc
$ sed -i -e "s,<AddressListsWebRemotePassword>,,g" 00-SetGlobalVarsAddressLists.rsc
```

First, upload the `00-SetGlobalVarsAddressLists` script to the router and execute it:

```
$ scp 00-SetGlobalVarsAddressLists.rsc admin@192.168.88.1:
$ ssh admin@192.168.88.1 "import 00-SetGlobalVarsAddressLists.rsc"
```

There's no need for a reboot - the variables will be instantiated right away. Additionally a scheduler entry is installed to ensure that such variables are being declared at boot time. Now, depending on what address lists you'd like to install simply select the respective installation script and upload it to the target router.

In the following example we'll install the dshield blacklist. Unlike other lists which can contain several thousands of entries the dshield list only consists of 20 entries and fits easily onto any routerboard hardware w/o eating up to many resources or wasting to many write cycles on the embedded flashrom:

```
$ scp 04-installBlacklistDshield.rsc admin@192.168.88.1:
$ ssh admin@192.168.88.1 "import 030-installBlacklistDshield.rsc"
[...]
```

That's it!

**Note:** Each script installs two system scripts. One for fetching the list from the remote web server. Another one for replacing existing entries once a new version becomes available. The installation script also places two scheduler entries to fetch and replace the respective address list. By default lists are being fetched once a day between 1 and 2am.

```
$ ssh admin@192.168.88.1 "/system script print brief; /system scheduler print brief"
```

### Firewall: Drop Malicious Traffic using Blacklists

All lists that contain a `Blacklist` within the name are added to the default address list named `blacklist`. Lets assume your router is connected to the internet through DSL and the modem is connected to ether1. Once the link is established internet traffic is routed through a pseudo interface usually called `pppoe-out1`. In the following example we'll use `all-ppp` as the in-interface to ensure the example works out-of-the-box with any router that's connected through a dial up connection.

Adding the following two firewall rules will ensure that any inbound or forwarding traffic originated from any ip address as part of the blacklist is being silently discarded.

```
$ ssh admin@192.168.88.1
[admin@MikroTik] > ip firewall filter add chain=input place-before=0 src-address-list=blacklist in-interface=all-ppp action=drop comment="block traffic from malicious networks"
[admin@MikroTik] > ip firewall filter add chain=forward place-before=0 src-address-list=blacklist in-interface=all-ppp action=drop comment="block traffic from malicious networks"
```

**Important:** This is a simple example to get you started. Both rules are installed on top of their respective chains - input and forward. That's before any stateful rule is able to grab return traffic for already established connections. Meaning, inserting the two rules above **WILL break** outbound connectivity to any of the ip addresses as part of the `blacklist`. That is for traffic originated from your router (input/output) as well as from any other network that's routed through it (forward). So if you need the ability to connect to any of the blacklisted addresses, the above mentioned rules have to be placed BELOW the stateful rules that's responsible for accepting already established connections (!)
