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

## Installation

### Global Variables

All installation scripts can be found in [ros/]. Each script takes care of installing a certain address list. Since all scripts are based on global variables declared within the `00-SetGlobalVarsAddressLists` script file this one has to modified and uploaded to the target router prior to any other script.

The following global variables are declared within 00-SetGlobalVarsAddressLists.rsc:

 * AddressListsWebRemoteHost
 * AddressListsWebRemoteUser
 * AddressListsWebRemotePassword

If access to the remote web server is not password protected you can declare


Workflow for installing blacklists

```
$ cd Desktop/
$ git clone https://github.com/jaydio/routeros-scripts
$ cd routeros-scripts/addresslists/ros
$ sed -i -e "s,<AddressListsWebRemoteHost>,lists.mikrotik.help,g" 00-SetGlobalVarsAddressLists.rsc
$ sed -i -e "s,<AddressListsWebRemoteUser>,,g" 00-SetGlobalVarsAddressLists.rsc
$ sed -i -e "s,<AddressListsWebRemotePassword>,,g" 00-SetGlobalVarsAddressLists.rsc

```

The installation scripts include required definitions for system scripts as well as respective scheduler entries.

## Building your own Central Repository (with IPAM support)

Within the [src/] folder you find all the tools required to set up your own central address list repository based on CentOS 7 running httpd.

The resulting address lists can be used together with the RouterOS scripts found in [ros/].

FIXME

