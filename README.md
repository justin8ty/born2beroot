# born2beroot Walkthrough

## Install VM

Folder should be in sgoinfre

Set memory to 1024 MB

Set storage to 12GB, or 30GB for bonus

## Install Debian

## Setup VM

### Sudo

A program to enable users to run programs using privileges of superuser.

A user can access this when added to sudo permission group.

Each group have its own GID.

### SSH Policies

For `permitrootlogin`:

`prohibit-password`: Allows root login via keys, but not passwords.

`no`: Disables root login entirely.

From this point onward, we can use SSH to configure the VM from host machine.

Connect with SSH:

`ssh jin-tan@localhost -p 4242`

### UFW Policies

A CLI frontend for configuring iptables.

**iptables <-> ufw examples**

Allow Port:

`iptables -A INPUT -p tcp --dport 22 -j ACCEPT`
`sudo ufw allow 4242`

Deny IP:

`iptables -A INPUT -s 192.168.1.100 -j DROP`
`sudo ufw deny from 192.168.1.100`

### Sudo Policies

Sudoers file handles privilege escalation policies. Use visudo for syntax-safe edits to sudoers.

`sudo visudo`

Changes:

`Defaults passwd_tries=3`

Sets a limit of 3 password attempts before locking out.

`Defaults badpass_message="Wrong password. Please try again."`

Customizes the error message for incorrect passwords.

`Defaults logfile="/var/log/sudo/sudo.log"`

Specifies the log file location for sudo activities.

`Defaults log_input, log_output`

Logs both input and output of sudo commands.

`Defaults requiretty`

Requires sudo to be run from a terminal.

`Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"`

Excludes folders from sudo.

## Password Policies

For `login.defs`:

PASS_MAX_DAYS: It's the max days till password expiration.

PASS_MIN_DAYS: It's the min days till password change.

PASS_WARN_AGE: It's the days till password warning.

For PAM:

minlen=10 ➤ The minimun characters a password must contain.

ucredit=-1 ➤ The password at least have to contain a capital letter. We must write it with a - sign, as is how it knows that's refering to minumum caracters; if we put a + sign it will refer to maximum characters.

dcredit=-1 ➤ The passworld at least have to containt a digit.

lcredit=-1 ➤ The password at least have to contain a lowercase letter.

maxrepeat=3 ➤ The password can not have the same character repited three contiusly times.

reject_username ➤ The password can not contain the username inside itself.

difok=7 ➤ The password it have to containt at least seven diferent characters from the last password ussed.

enforce_for_root ➤ We will implement this password policy to root.

## Startup Script

This script collects various system information and displays it using the `wall` command.

```
cd /usr/local/bin/
sh monitoring.sh
```

### Lines Explained with Syntax

1. **Shebang**
   ```bash
   #!/bin/bash
   ```
   - **Purpose:** Specifies the script should be run using the Bash shell.

2. **Architecture**
   ```bash
   arch=$(uname -a)
   ```
   - **`uname -a`:** Displays system information (kernel name, hostname, kernel version, etc.).
   - **Purpose:** Stores system architecture information in the variable `arch`.

3. **CPU Physical**
   ```bash
   cpuf=$(grep "physical id" /proc/cpuinfo | wc -l)
   ```
   - **`grep "physical id" /proc/cpuinfo`:** Searches for the string "physical id" in the `/proc/cpuinfo` file.
   - **`wc -l`:** Counts the number of lines.
   - **Purpose:** Counts the number of physical CPU cores.

4. **CPU Virtual**
   ```bash
   cpuv=$(grep "processor" /proc/cpuinfo | wc -l)
   ```
   - **`grep "processor" /proc/cpuinfo`:** Searches for the string "processor" in the `/proc/cpuinfo` file.
   - **`wc -l`:** Counts the number of lines.
   - **Purpose:** Counts the number of virtual CPU cores (threads).

5. **RAM Usage**
   ```bash
   ram_total=$(free --mega | awk '$1 == "Mem:" {print $2}')
   ram_use=$(free --mega | awk '$1 == "Mem:" {print $3}')
   ram_percent=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
   ```
   - **`free --mega`:** Displays memory usage in megabytes.
   - **`awk '$1 == "Mem:" {print $2}'`:** Extracts total memory.
   - **`awk '$1 == "Mem:" {print $3}'`:** Extracts used memory.
   - **`awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}'`:** Calculates and formats memory usage percentage.
   - **Purpose:** Stores total, used, and percentage of RAM usage.

6. **Disk Usage**
   ```bash
   disk_total=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_t += $2} END {printf ("%.1fGb\n"), disk_t/1024}')
   disk_use=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} END {print disk_u}')
   disk_percent=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{disk_u += $3} {disk_t+= $2} END {printf("%d"), disk_u/disk_t*100}')
   ```
   - **`df -m`:** Displays disk space usage in megabytes.
   - **`grep "/dev/"`:** Filters device filesystems.
   - **`grep -v "/boot"`:** Excludes the `/boot` directory.
   - **`awk '{disk_t += $2} END {printf ("%.1fGb\n"), disk_t/1024}'`:** Sums total disk space and converts to gigabytes.
   - **`awk '{disk_u += $3} END {print disk_u}'`:** Sums used disk space.
   - **`awk '{disk_u += $3} {disk_t+= $2} END {printf("%d"), disk_u/disk_t*100}'`:** Calculates and formats disk usage percentage.
   - **Purpose:** Stores total, used, and percentage of disk space usage.

7. **CPU Load**
   Can also use vmstat to manually calculate.
   ```bash
   cpul=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
   cpu_op=$(expr 100 - $cpul)
   cpu_fin=$(printf "%.1f" $cpu_op)
   ```
   - **`vmstat 1 2`:** Runs `vmstat` command twice with 1-second interval.
   - **`tail -1`:** Takes the last line of the output.
   - **`awk '{printf $15}'`:** Extracts the 15th field (idle CPU percentage).
   - **`expr 100 - $cpul`:** Calculates used CPU percentage.
   - **`printf "%.1f" $cpu_op`:** Formats the CPU usage percentage.
   - **Purpose:** Stores CPU usage percentage.

8. **Last Boot**
   ```bash
   lb=$(who -b | awk '$1 == "system" {print $3 " " $4}')
   ```
   - **`who -b`:** Displays last boot time.
   - **`awk '$1 == "system" {print $3 " " $4}'`:** Extracts the boot time.
   - **Purpose:** Stores the last boot time.

9. **LVM Use**
   ```bash
   lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)
   ```
   - **`lsblk`:** Lists block devices.
   - **`grep "lvm"`:** Searches for LVM (Logical Volume Manager) entries.
   - **`wc -l`:** Counts the number of lines.
   - **Purpose:** Checks if LVM is used and stores "yes" or "no".

10. **TCP Connections**
    ```bash
    tcpc=$(ss -ta | grep ESTAB | wc -l)
    ```
    - **`ss -ta`:** Lists all TCP sockets.
    - **`grep ESTAB`:** Filters established connections.
    - **`wc -l`:** Counts the number of lines.
    - **Purpose:** Counts the number of established TCP connections.

11. **User Log**
    ```bash
    ulog=$(users | wc -w)
    ```
    - **`users`:** Lists logged-in users.
    - **`wc -w`:** Counts the number of words.
    - **Purpose:** Counts the number of logged-in users.

12. **Network**
    ```bash
    ip=$(hostname -I)
    mac=$(ip link | grep "link/ether" | awk '{print $2}')
    ```
    - **`hostname -I`:** Displays the IP address of the host.
    - **`ip link | grep "link/ether"`:** Filters the network interface containing MAC address.
    - **`awk '{print $2}'`:** Extracts the MAC address.
    - **Purpose:** Stores IP and MAC addresses.

13. **Sudo Commands**
    ```bash
    cmnd=$(journalctl _COMM=sudo | grep COMMAND | wc -l)
    ```
    - **`journalctl _COMM=sudo`:** Filters logs for `sudo` commands.
    - **`grep COMMAND`:** Searches for `COMMAND` entries.
    - **`wc -l`:** Counts the number of lines.
    - **Purpose:** Counts the number of `sudo` commands executed.

14. **Display Information with `wall`**
    ```bash
    wall "	Architecture: $arch
    	CPU physical: $cpuf
    	vCPU: $cpuv
    	Memory Usage: $ram_use/${ram_total}MB ($ram_percent%)
    	Disk Usage: $disk_use/${disk_total} ($disk_percent%)
    	CPU load: $cpu_fin%
    	Last boot: $lb
    	LVM use: $lvmu
    	Connections TCP: $tcpc ESTABLISHED
    	User log: $ulog
    	Network: IP $ip ($mac)
    	Sudo: $cmnd cmd"
    ```
    - **`wall`:** Broadcasts a message to all logged-in users.
    - **Purpose:** Displays the collected system information.

## Crontab

A background process manager for scheduling and automating tasks.

## Bonus Services

```
sudo apt install lighttpd
```

## Signature

Store VM in `~/VirtualBox VMs/`

Obtain signature in sha1 format:

`shasum Born2beRoot.vdi`

## Docs

**Theory**

- https://youtu.be/42iQKuQodW4
- https://www.nakivo.com/blog/virtualbox-network-setting-guide/
- https://github.com/edithturn/42-silicon-valley-netwhat
- https://www.youtube.com/watch?v=9J1nJOivdyw
- https://www.freecodecamp.org/news/file-systems-architecture-explained/
- https://mathieu-soysal.gitbook.io/born2beroot
- https://forums.debian.net/viewtopic.php?t=11065
- https://www.linuxatemyram.com/
- https://unix.stackexchange.com/questions/33541/free-output-format/33549
- https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file
- https://www.cloudflare.com/learning/access-management/what-is-ssh/
- https://www.ssh.com/academy/ssh/protocol

**Practical**

- https://42-cursus.gitbook.io/guide/rank-01/born2beroot
- https://mathieu-soysal.gitbook.io/born2beroot/
- https://github.com/pasqualerossi/Born2BeRoot-Guide
- https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lamp-on-debian-10
- https://docs.google.com/document/d/1-BwCO0udUP7MhRh81Y681zz0BalXtKFtte_FHJc6G4s/edit

## Unix Filesystem

| Name     | Description                                                                                            |
| -------- | ------------------------------------------------------------------------------------------------------ |
| `/`      | The top-level directory in the filesystem hierarchy, contains all other directories and files.         |
| `/bin`   | Essential command binaries, contains commonly used commands like `ls`, `cp`, `mv`, etc.                |
| `/sbin`  | System binaries, contains essential system management and administrative commands.                     |
| `/etc`   | Configuration files, contains system-wide configuration files and scripts.                             |
| `/dev`   | Device files, contains files representing hardware devices.                                            |
| `/boot`  | Files used during boot process.                                                                        |
| `/home`  | User home directories, contains personal directories for all users.                                    |
| `/lib`   | Shared libraries, contains essential shared libraries and kernel modules.                              |
| `/lib64` | 64-bit shared libraries, contains essential 64-bit shared libraries.                                   |
| `/media` | Mount points for removable media, contains directories for mounting removable media like USB drives.   |
| `/mnt`   | Temporary mount point, contains directories for temporarily mounting filesystems.                      |
| `/opt`   | Optional software packages, contains add-on application software packages.                             |
| `/proc`  | Process and system information, contains virtual filesystem providing process and kernel information.  |
| `/root`  | Home directory for the root user, contains personal files and settings for the root user.              |
| `/run`   | Runtime variable data, contains information about the running system since last boot.                  |
| `/srv`   | Data for services, contains data served by the system, such as websites.                               |
| `/sys`   | System information, contains virtual filesystem with system and hardware information.                  |
| `/tmp`   | Temporary files, contains temporary files created by users and applications.                           |
| `/usr`   | Secondary hierarchy, contains user programs and data.                                                  |
| `/var`   | Variable files, contains files that change frequently, such as logs, mail spools, and temporary files. |

| Name        | Description                                |
| ----------- | ------------------------------------------ |
| `/usr/bin`  | Non-essential command binaries.            |
| `/usr/sbin` | Non-essential system binaries.             |
| `/usr/lib`  | Libraries for `/usr/bin` and `/usr/sbin`.  |

| Name        | Description                                |
| ----------- | ------------------------------------------ |
| `/var/log`  | Log files.                                 |
| `/var/tmp`  | Temporary files preserved between reboots. |
| `/var/lib`  | State information.                         |