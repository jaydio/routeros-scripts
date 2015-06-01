# rosbackup.sh - A simple way to back up your RouterOS

This script provides very basic functionality in order to back up multiple routers remotely using SSH.

Features:

 * Uses SSH to connect (supports arguments e.g. for using pubkey authentication)
 * Automatically creates a folder for each router to be backed up
 * a binary as well as a router script export

Missing features:

 * Implement basic logging functionality
 * Add error handling/reporting e.g. skip iteration if router isn't reachable,providing a detailed error (ping/ssh return code)
 * Add email notifications using board utilities for cross-platform support (sendmail compat)
 * Integrate functionality to remove backups older than a given count of days (use find)

## OS Compatibility

The script was tested successfully on the following linux distributions:

 * CentOS 6
 * CentOS 7
 * Fedora 21
 * Fedora 22

Even though there's no guaranteee the script should work fine on other platforms as well including Debian and its derivates such as Ubuntu.

## Backup Directory Layout

```
$ tree
.
├── MikroTik-192.168.200.1-ros6.29-tile
│   ├── MikroTik-192.168.200.1-ros6.29-tile-0602150124.backup
│   ├── MikroTik-192.168.200.1-ros6.29-tile-0602150124.INFO.txt
│   └── MikroTik-192.168.200.1-ros6.29-tile-0602150124.rsc
└── rosbackup.sh
```

## Installation

### Server: Generating an SSH Keypair

First log in to your linux server using the user account you'd like to store your backups with. Then generate an the ssh keypair necessary for the script to connect to all routers w/o the need to enter a password (non-interactive or public key authentication)

```
server ~$ test -d .ssh || mkdir .ssh && chmod 0700 .ssh
server ~$ ssh-keygen -t DSA -b 1024 -C "rosbackup" -f .ssh/id_dsa_rosbackup
Generating public/private DSA key pair.
Enter passphrase (empty for no passphrase): <PRESS ENTER>
Enter same passphrase again: <PRESS ENTER>
Your identification has been saved in .ssh/id_dsa_rosbackup.
Your public key has been saved in .ssh/id_dsa_rosbackup.pub.
```
When being prompted for a passphrase hit return to use an empty passphrase. This way the private key can be used by the backup script without the need for entering a passphrase or using an ssh agent.

Following this approach you have to make sure to secure access to the user account and therefore to the private key used to back up your routers (!) Even better - consider using a machine dedicated to the purpose of fetching and storing your backups and do not run services other than ssh.

As you can see above the pair consists of two keys;

 * Private - has to stay on the linux server at all times (!)
 * Public - to be installed on all target routers for the backup user

### Router: Create Backup User and Upload SSH Public Key

Upload the ssh public key from the server to the router and assign it to a backup user

```
server ~$ scp .ssh/id_dsa_rosbackup.pub admin@<routeripaddress>:
[admin@MikroTik] > user add name=backup group=full
[admin@MikroTik] > user ssh-keys import public-key-file=id_dsa_rosbackup.pub user=backup
```

Repeat the following steps for every router you'd like to back up using this script.

### Server: Script Installation

You can now either clone the repository to your workstation and edit the configuration locally and then upload the script to the server.

The way below describes how to clone the repository directly to the server (way described below).

```
server ~$ git clone https://github.com/jaydio/routeros-scripts
server ~$ cd routeros-scripts/backup
server ~$ cp rosbackup.sh /usr/local/sbin/
server ~$ chmod 700 /usr/local/sbin/rosbackup.sh
```
Now open the script `/usr/local/sbin/rosbackup.sh` and change the following variables/parameters:

 * **SSHUSER** - The username to use when connecting to routers (same for all routers)
 * **SSHARGS** - Arguments passed to the `ssh` command when connecting to routers. By default it expects the private key within the `~/.ssh` - the tilde resolves to the home folder of the user you've used to login. With root the path would look like this -> `/root/.ssh`
 * **BACKUPPATH_PARENT** - The parent path under which to store backups. Within this path the script will create a directory per router based on the name, ip address, ros version and architecture. Defaults to the curren working directory.
 * **ROUTERS** - An array of ip addresses of all target routers that the script should back up. There's no limit on how many routers you can add.

Having one router configured now do a dry run by calling the script using its full path to make sure everything works.

```
~$ /usr/local/sbin/rosbackup.sh
>>>> Starting backup of MikroTik (192.168.200.1) running RouterOS version 6.29 (tile) ..
Configuration backup saved
DCUPLNK01.RT-10.99.238.1-ros6.29-tile-0602150124.backup    100%   99KB  98.9KB/s   00:00    
DCUPLNK01.RT-10.99.238.1-ros6.29-tile-0602150124.rsc       100%   67KB  67.2KB/s   00:00  
```

That's it!

