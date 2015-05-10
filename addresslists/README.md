# Automated deployment of address lists

In larger deployments such as provider networks it is beneficial to synchronize address lists across routers.

For this a central web server comes in handy since it is firewall friendly and provide for additional security using SSL/TLS and basic authentication.

Address lists can be further subdivided into the following categories:

 * Public blacklists (PE, provider edge)
 * Internal blacklists (P, provider core)
 * IPAM export (P+PE, provider core & edge)

An IP address management export can be taken from any IPAM solution including - but not limited to - [OpenNetAdmin](http://opennetadmin.com/), [NOC](https://kb.nocproject.org/) and [NIPAP](http://spritelink.github.io/NIPAP/) and usually contains either a subset or all internal subnets, hosts and netblocks.

Address lists in RouterOS support the following entry types:

 * Single ip address (e.g. 10.99.99.1)
 * Subnet using the CIDR notation (e.g. 10.99.99.0/24)
 * Range of ip addresses (e.g. 10.99.99.100-10.99.99.200)

See [Manual:IP/Firewall/Address list](http://wiki.mikrotik.com/wiki/Manual:IP/Firewall/Address_list) for further details.

## Conditionals

The following conditions apply when using the scripts located in [ros/](ros/):

 * Installing a new address list involves the following steps
   * Check if the address list file is present on the router's file system
   * If present, remove all pre-existing entries identified by address list specific comment (e.g. "IPAM", "OpenBL" or "DShield")
   * Once removed, attempt to import the address list file from the local file system
   * If the import succeeds, and only then, purge the address list file from the local file system
   * If the address list file is missing for whatever reason, the replace script exit with a warning
   * If the address is smaller than 1KB (Kilobyte) it will not be used
 * The fetch script has no way to determine if ..
   * .. the list on the remote server contains newer entries than those currently installed
   * .. the address list file contains any errors (e.g. file was truncated on the remote server or during transfer)
 * Fetching a broken address list file WILL cause trouble
 * When an address list was fetched successfully 

Everyone should be clear about the fact that this whole setup is fairly fragile and should be used with caution. The scripts mentioned at this point are currently being used in production and so far haven't caused any severe outages. However, it should be noted that almost all our routers are located in walking distance. It is advised to take pre-measures e.g. hard code those firewall rules responsible for allowing administrative access. This way you can at least ensure that the router's managemenet address stays reachable.

## Address Mappings

Considering an export from IPAM - netblocks can be mapped using a range of ip addresses, subnets using the more common CIDR notation and hosts by using their respective ip address(es). If a host is configured with more than one ip address within the same network, the interface name or subnet name can be appended to the respective list name.

Sample address list exported from IPAM:

```
/ip firewall address-list
add list=HOST-SERVERNET.host01.example.com address=10.10.0.2 comment=IPAM
add list=HOST-SERVERNET.host01.example.com address=10.10.0.3 comment=IPAM
add list=NETBLOCK-BRANCH2 address=10.250.10.0-10.250.20.255 comment=IPAM
add list=SUBNET-SERVERNET address=10.10.10.0/24 comment=IPAM
```

## Installation Scripts

### Global Variables

All installation scripts can be found in [ros/](ros/). Each script takes care of installing a certain address list. Since all scripts are based on global variables declared within the `00-SetGlobalVarsAddressLists` script file this one has to modified and uploaded to the target router prior to any other script.

The following global variables are declared within 00-SetGlobalVarsAddressLists.rsc:

 * AddressListsWebRemoteHost
 * AddressListsWebRemoteUser
 * AddressListsWebRemotePassword

Usually it is advisable to install password protection (basic authentication) on the web server serving the address lists. Especially when address lists are generated using sensitive information from IPAM. However, when using a public service such as [lists.mikrotik.help](https://lists.mikrotik.help) access is usually not password protected. In case authentication is not required, make sure to set an empty values for the variable `AddressListsWebRemoteUser`.

### Installation Workflow

The following workflow gets you started using my public blacklist service hosted via [lists.mikrotik.help](http://lists.mikrotik.help/). The provided address lists are being updated hourly.

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

There's no need for a reboot - the variables will be available right away. Additionally a scheduler entry is installed to ensure that such variables are being declared during boot time. Now, depending on what address lists you'd like to install, select the respective installation script and upload it to the target router.

In the following example we'll try to install the dshield blacklist. Unlike other lists which can contain several thousands of entries the dshield list only consists of 20 entries and fits easily onto any routerboard hardware w/o eating up to many resources:

```
$ scp 04-installBlacklistDshield.rsc admin@192.168.88.1:
$ ssh admin@192.168.88.1 "import 04-installBlacklistDshield.rsc"
[...]
```

That's it!

**Note:** Each script installs two system scripts. One for fetching the list from the remote web server. Another one for replacing existing entries once a new version becomes available. The installation script also places two scheduler entries to fetch and replace the respective address list. By default lists are being fetched once a day between 1 and 2am.

```
$ ssh admin@192.168.88.1 "/system script print brief; /system scheduler print brief"
```

### Firewall: Drop Malicious Traffic using Blacklists

All lists that contain a `Blacklist` within the file name are added to the default address list named `blacklist`. Lets assume your router is connected to the internet through DSL and the modem is connected to ether1. Once the link is established internet traffic is routed through a pseudo interface usually called pppoe0. In the following example we'll use `all-ppp` as the in-interface to ensure the example works out-of-the-box with any router that's connected through a dial up connection.

Adding the following two firewall rules will ensure that any inbound or forwarding traffic originated from any ip address on the blacklist is being silently discarded.

```
$ ssh admin@192.168.88.1
[admin@MikroTik] > ip firewall filter add chain=input place-before=0 src-address-list=blacklist in-interface=all-ppp action=drop comment="block traffic from malicious networks"
[admin@MikroTik] > ip firewall filter add chain=forward place-before=0 src-address-list=blacklist in-interface=all-ppp action=drop comment="block traffic from malicious networks"
```

**Important:** Both rules are installed on top of their respective chains - input and forward. That's before any stateful rule could grab return traffic for already established connections. Meaning, inserting the two rules above WILL break outbound connectivity to any of the ip addresses as part of the `blacklist`. That is for traffic originated from your router (input/output) as well as from any other network that's routed through it (forward). So if you need the ability to connect to any of the blacklisted addresses, the above mentioned rules have to be placed BELOW the stateful rules that's responsible for accepting already established connections (!)

## Building your own Central Address List Repository

Within the [src/](src/) folder you find all the tools required to set up your own central address list repository based on CentOS 7 running httpd.

The resulting address lists can be used together with the RouterOS scripts found in [ros/](ros/).
