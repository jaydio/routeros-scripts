# rosbackup.sh - A simple back up script for RouterOS

Features:

 * Utilizes SSH via public key authentication (non-interactive/passwordless)
 * Automatically creates an encoded backup directory for each router
 * Stores both; a full export and an architecture specific binary backup
 * Utilizes SSH session multiplexing for optimized performance

Missing features:

 * Implement basic logging functionality
 * Add error handling/reporting e.g. skip iteration if router isn't reachable, providing a detailed error output
 * Add cross-platform support for email notifications using linux board utilities (sendmail compat)
 * Integrate functionality to remove backups older than a given count of days (find)

## OS Compatibility

The script was tested successfully on the following distros:

 * CentOS 6
 * CentOS 7
 * Fedora 21
 * Fedora 22
 * Fedora 23

The script should work fine on other platforms as well including Debian and its derivates (such as Ubuntu).

## OpenSSH release 7.0 disables support for DSS based Host and User Keys by default (August 2015)

Starting with OpenSSH 7.0 support for ssh-dss, ssh-dss-cert-* host and user keys is disabled by default at run-time. That means when using this backup script on bleeding edge platforms such as Fedora Linux 23 it won't work out of the box when using DSA keys. In order to avoid compatibility issues consider using only RSA keys.

**Source:** http://www.openssh.com/txt/release-7.0

## SSH on Steroids: Session Multiplexing

This script utilizes SSH session multiplexing to avoid the overhead caused by having to establish a separate SSH session for each command when executing a series of commands on a remote host.

From **SSH_CONFIG (5)** ...

> [...]
> **ControlMaster**:
> Enables the sharing of multiple sessions over a single network
> connection.  When set to “yes”, ssh(1) will listen for connec‐
> tions on a control socket specified using the ControlPath argu‐
> ment.  Additional sessions can connect to this socket using the
> same ControlPath with ControlMaster set to “no” (the default).
> These sessions will try to reuse the master instance's network
> connection rather than initiating new ones, but will fall back to
> connecting normally if the control socket does not exist, or is
> [...]

For session multiplexing to work no special configuration is required. The default parameters are defined using the ```$SSHARGS``` variable at the beginning of the script.

## Backup Directory Layout

The script automatically creates a separate backup directory for each router being backed up.

The following information is encoded within the directory and filenames:

 * Identity of the target router (e.g. ```ROUTERNAME```, ```MikroTik``` etc.)
 * The ip address used by the script to connect (e.g. ```192.168.200.1```)
 * The RouterOS version and architecture (e.g. ```ros6.29``` and ```tile```, ```mipsbe``` [...] respectively)

The location where backups are being stored is defined within  ```$BACKUPPATH_PARENT``` at the beginning of the script. It defaults to the current working directory (CWD) which defaults to the same directory where the script was installed. E.g. if the script was installed under ```/home/$USER/rosbackup.sh``` all backups will be stored in the user's home directory under ```/home/$USER```..

Sample directory structure:

```
[rosbackup@server ~]$ tree
.
├── ROUTERNAME-192.168.200.1-ros6.29-tile
│   ├── ROUTERNAME-192.168.200.1-ros6.29-tile-0602160124.backup
│   ├── ROUTERNAME-192.168.200.1-ros6.29-tile-0602160124.INFO.txt
│   └── ROUTERNAME-192.168.200.1-ros6.29-tile-0602160124.rsc
└── rosbackup.sh
```

## Installation

### Server: Generating an SSH Keypair

First you'll have to log in to your linux server.

**Hint:** It's a good idea to create a separate user account under which to run the script and safekeep your backups.

**Hint:** In the following examples the dollar sign ($) indicates that the respective commands are to be executed as a regular user (**not** root). Please don't just copy & paste the commands but type them manually to understand the workflow. However, if you do have to copy & paste make sure **NOT TO** include the dollar sign (!) as it is **NOT** part of the actual command. All actual commands are prefixed with a ```server $ ``` and all further output is considered the actual output of the command itself (!)

Once you've logged in to your user account the next step is to generate an RSA keypair. It will be used by the backup script to log into target routers without the need for a password. This method is also being referred to as **non-interactive** or **public key authentication**.


Lets begin by creating a separate system user and generating an RSA keypair:

```
[root@server ~]# useradd rosbackup
[root@server ~]# su - rosbackup
[rosbackup@server ~]$ test -d .ssh || mkdir .ssh && chmod 0700 .ssh
[rosbackup@server ~]$ ssh-keygen -t RSA -b 4096 -N '' -C "rosbackup@$(hostname -f)" -f .ssh/id_rsa_rosbackup
Your identification has been saved in .ssh/id_rsa_rosbackup.
Your public key has been saved in .ssh/id_rsa_rosbackup.pub.
The key fingerprint is:
04:fb:3e:9b:d4:9d:e0:6e:15:6b:cd:xx:xx:xx:xx:xx rosbackup@myserver

```

The private key is generated without a passphrase which means it can be used by the backup script without the need for entering a passphrase or configuring an SSH agent.

As you seen above the keypair basically consists of two parts:

 * ```~/.ssh/id_rsa_rosbackup``` - The private key which should never leave the server/host (!)
 * ```~/.ssh/id_rsa_rosbackup.pub``` - The public key which is to be installed on all target routers (for the backup user)

**WARNING:** Everyone with root access to your server or general access to the user account used to run the backup script essentially has **full access to all your routers** which are being backed up (!) Keep your ```.ssh``` directory safe and **do not share access to the server our your user account!** You're advised to also use ssh public key authentication to secure your root and user account and disable password based authentication altogether. Also consider using a server dedicated to the purpose of fetching and storing your backups and do not run any other services aside from the backup script (!)

### Router: Create Backup User and Upload SSH Public Key

Now upload the public key to the first router and assign it to the backup user. This will allow your server to log in as the backup user using its corresponding private key:

```
[rosbackup@server ~]$ scp .ssh/id_rsa_rosbackup.pub admin@192.168.88.1:
[rosbackup@server ~]$ ssh admin@192.168.88.1 "user add name=backup group=full password=\"$(openssl rand -base64 32)\""
[rosbackup@server ~]$ ssh admin@192.168.88.1 "user ssh-keys import public-key-file=id_rsa_rosbackup.pub user=backup"
```

**Hint:** RouterOS seems to automatically disable interactive authentication via password for users that have a public key installed. Creating a user without a password and public key will allow anyone to log in as the backup user **using an empty string as the password** (!!) The second command uses openssl to generate a random alpha-numeric string to be used as the password for the backup user. This command has to be executed on the server as it uses command substitution which in this case is only supported on the linux shell (being bash by default).

Repeat the above steps for every router that you'd like to back up by replacing the sample ip address with the actual ip address of the target router(s). Of course all ip addresses or hostnames (when using dynamic dns) have to be added to the ```ROUTERS[]``` array.

### Server: Script Installation

The easiest way to install the script is by downloading it directly to the server using wget and making it executable:

```
[rosbackup@server ~]$ wget https://raw.githubusercontent.com/jaydio/routeros-scripts/master/backup/rosbackup.sh
[rosbackup@server ~]$ chmod 700 rosbackup.sh
```
Now open the script ```rosbackup.sh``` e.g. using `nano rosbackup.sh` or `vim rosbackup.sh` and change the following variables to fit your needs. If you have followed this guide closely the defaults should get you started.

 * `$SSHUSER` - Specify the username to be used when connecting to routers (defaults to ``backup``)
 * `$BACKUPPATH_PARENT` - The parent directory under which to store backups. Within this path the script will create a directory per router based on its identity, ip address, ros version and architecture. Defaults to the current working directory (home directory).
 * `$BACKUPPASSWORD` - The password to be used when securing binary backups created via ``/system backup save`` (extension ``.backup``). RouterOS by default secures binary backups with the actual password of the system user doing the backup. This variable overwrites the password for all backups done on all routers allowing it to be used for restoring abritary backups.

After configuring your target routers you need to add them to the `ROUTERS[]` array so the script knows which routers to back up.

#### Configuration Examples

 * `$ROUTERS` - An array of ip addresses of all target routers that the script should back up. There's no artificial limit on how many routers you can backup.

Adding three routers to be backed up using both; ip addresses and a fully qualified domain name (FQDN):

```
ROUTERS=()
ROUTERS+=("192.168.200.1");
ROUTERS+=("myrouter174.dyndns.org");
ROUTERS+=("192.168.200.3");
```

Yet another example specifying a range of ip addresses as part of the same class C subnet (`192.168.200.1` to `192.168.200.254`):

```
ROUTERS=()
ROUTERS+=($(seq -f "192.168.200.%g" 1 255));
```

The following

 * **SSHARGS** - Arguments passed to the `ssh` command when connecting to routers. By default it expects the private key within the `~/.ssh` - the tilde resolves to the home folder of the user you've used to login. With root the path would look like this -> `/root/.ssh`

#### Fire!

Having added your target router(s) to the configuration you may now run the script by calling it directly from your home directory:

```
[rosbackup@server ~]$ ./rosbackup.sh
>>>> Starting backup of MikroTik (192.168.200.1) running RouterOS version 6.29 (tile) ..
Configuration backup saved
ROUTERNAME-192.168.200.1-ros6.29-tile-0602160124.backup    100%   99KB  98.9KB/s   00:00
ROUTERNAME-192.168.200.1-ros6.29-tile-0602160124.rsc       100%   67KB  67.2KB/s   00:00
```

That's it!

