# Monitoring Explained

Sure, let's break down each part of this script to explain what it does and how it works. This script collects various system statistics and displays them. Here's a detailed explanation of each command and syntax:

## 1. **System Architecture**

```bash
arch=$(uname -a)
```
- **`uname -a`**: This command outputs the system information, including the kernel name, version, and machine hardware name.
- **`arch=$(...)`**: This stores the output of `uname -a` into the variable `arch`.

## 2. **Physical and Virtual CPU Count**

```bash
pcpu=$(grep "physical id" /proc/cpuinfo | wc -l)
vcpu=$(grep "processor" /proc/cpuinfo | wc -l)
```
- **`/proc/cpuinfo`**: This file contains details about the CPU(s).
- **`grep "physical id"`**: Searches for lines containing "physical id", indicating physical CPUs.
- **`wc -l`**: Counts the number of lines, thus giving the number of physical CPUs (`pcpu`).
- **`grep "processor"`**: Searches for lines containing "processor", indicating logical processors or virtual CPUs (`vcpu`).

## 3. **RAM Usage**

```bash
tram=$(free --mega | awk '$1 == "Mem:" {print $2}')
uram=$(free --mega | awk '$1 == "Mem:" {print $3}')
pram=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
```
- **`free --mega`**: Displays memory usage, with sizes in megabytes.
- **`awk '$1 == "Mem:" {print $...}'`**: Filters lines where the first column is "Mem:" and prints the total memory (`tram`), used memory (`uram`).
- **`{printf("%.2f"), $3/$2*100}`**: Calculates the percentage of used memory (`pram`).
    - `$3` is the used memory in MB.
    - `$2` is the total memory in MB.
    - `$3/$2*100` calculates the percentage of used memory.
    - `printf("%.2f")` formats this percentage as a floating-point number with two decimal places.

## 4. **Disk Usage**

```bash
tdisk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{td += $2} END {printf ("%.1fGb\n"), td/1024}')
```

- **`df -m`**: This command shows disk space usage for all mounted filesystems, with sizes displayed in megabytes (MB).
- **`grep "/dev/"`**: Filters the output to include only lines that represent mounted devices (i.e., physical or logical drives). The `/dev/` directory typically contains device files.
- **`grep -v "/boot"`**: The `-v` flag inverts the match, excluding lines that contain `/boot`. This is likely because `/boot` is often a separate, relatively small partition that the user does not want to include in the total disk usage calculation.
- **`awk '{td += $2} END {printf ("%.1fGb\n"), td/1024}'`**:
  - **`'{td += $2}'`**: Inside the `{}` braces, `awk` processes each line of input. `$2` refers to the second column in each line of the filtered `df` output, which represents the total size of the filesystem in MB. The `td += $2` operation adds the size from each line to a running total `td`.
  - **`END {printf ("%.1fGb\n"), td/1024}`**: After processing all lines, the `END` block is executed. Here, `td` contains the sum of all sizes from the relevant filesystems in MB. This total is divided by 1024 to convert it into gigabytes (GB). The `printf` function formats the output to one decimal place (`%.1f`) followed by "Gb".

## 5. **CPU Load**

```bash
cpuidle=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
cpucalc=$(expr 100 - $cpuidle)
cpul=$(printf "%.1f" $cpucalc)
```

- **`vmstat 1 2`**: `vmstat` (Virtual Memory Statistics) reports on system performance. `1 2` means it will sample data every second twice, which helps in obtaining a more current snapshot.
- **`tail -1`**: This extracts the last line from the `vmstat` output, which contains the most recent system performance data.
- **`awk '{printf $15}'`**: The `awk` command prints the 15th field of the input, which corresponds to the CPU idle percentage. In `vmstat` output, this represents the time the CPU spends idle.
- **`cpucalc=$(expr 100 - $cpuidle)`**: `expr` is used for integer calculations. Here, it calculates the percentage of CPU load by subtracting the idle percentage from 100.
- **`cpul=$(printf "%.1f" $cpucalc)`**: Formats the calculated CPU load as a floating-point number with one decimal place.

## 6. **Last Boot Time**

```bash
lboot=$(who -b | awk '$1 == "system" {print $3 " " $4}')
```
- **`who -b`**: Shows the last system boot time.
- **`awk '$1 == "system" {print $3 " " $4}'`**: Extracts the date and time of the last boot.

## 7. **LVM Usage**

```bash
lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)
```
- **`lsblk`**: Lists information about all available block devices (like hard drives).
- **`grep "lvm"`**: Filters the output for lines containing "lvm", indicating that the block device is part of a Logical Volume Manager (LVM) setup.
- **`wc -l`**: Counts the number of lines that contain "lvm".
- **`if ... then ... fi`**: This is a conditional statement that checks if the count of "lvm" lines is greater than 0. If true, it echoes "yes", indicating that LVM is in use; otherwise, it echoes "no".

## 8. **TCP Connections**

```bash
tcpc=$(ss -ta | grep ESTAB | wc -l)
```
- **`ss -ta`**: The `ss` command shows socket statistics. The `-t` flag filters for TCP connections, and the `-a` flag shows all sockets, including listening ones.
- **`grep ESTAB`**: Filters the output to include only lines containing "ESTAB", indicating established TCP connections.
- **`wc -l`**: Counts the number of lines in the filtered output, which corresponds to the number of established connections.

## 9. **User Logins**

```bash
ulog=$(users | wc -w)
```
- **`users`**: Lists logged-in users.
- **`wc -w`**: Counts the number of words, representing the number of users.

## 10. **Network Information**

```bash
ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')
```
- **`hostname -I`**: Shows the IP addresses of the host.
- **`ip link`**: Displays network interfaces.
- **`grep "link/ether"`**: Filters for lines containing the MAC address.
- **`awk '{print $2}'`**: Extracts the MAC address.

## 11. **Sudo Command Count**

```bash
ncmd=$(journalctl _COMM=sudo | grep COMMAND | wc -l)
```
- **`journalctl _COMM=sudo`**: Shows log entries related to the `sudo` command.
- **`grep COMMAND`**: Filters for lines containing "COMMAND", indicating a sudo command execution.
- **`wc -l`**: Counts the number of sudo commands executed.

## 12. **Displaying Information**

```bash
wall "  Architecture: $arch
        CPU physical: $pcpu
        vCPU: $vcpu
        Memory Usage: $uram/${tram}MB ($pram%)
        Disk Usage: $udisk/${tdisk} ($pdisk%)
        CPU load: $cpul%
        Last boot: $lboot
        LVM use: $lvmu
        Connections TCP: $tcpc ESTABLISHED
        User log: $ulog
        Network: IP $ip ($mac)
        Sudo: $ncmd cmd"
```
- **`wall`**: Sends a message to all users currently logged in.
- **`${variable}`**: Used to insert the value of a variable into the output.

This script gathers and displays various system metrics, providing a comprehensive overview of system status.

## How `grep` & `wc -l` Works

Consider the following:

```
ss -ta | grep ESTAB | wc -l
```

Output will be:

```
State      Recv-Q Send-Q Local Address:Port Peer Address:Port
ESTAB      0      0      192.168.1.100:22  192.168.1.101:54321
LISTEN     0      128    0.0.0.0:80         0.0.0.0:*
ESTAB      0      0      192.168.1.100:80  192.168.1.102:54322
```

`grep ESTAB` will filter for lines matching a pattern (ESTAB). 

Filter will be:

```
ESTAB      0      0      192.168.1.100:22  192.168.1.101:54321
ESTAB      0      0      192.168.1.100:80  192.168.1.102:54322
```

`wc -l` counts the # of filtered lines, and produces a numerical output (2).

Consider the following:

```
df -m | grep "/dev/" | grep -v "/boot"
```

`grep "/dev"` will exclude lines matching a pattern (/dev).

Output will be:

```
/dev/mapper/LVMGroup-root          9287  1638      7157  19% /
tmpfs                               481     0       481   0% /dev/shm
/dev/mapper/LVMGroup-home          4611     1      4357   1% /home
/dev/mapper/LVMGroup-srv           2743     1      2584   1% /srv
/dev/mapper/LVMGroup-tmp           2743     1      2584   1% /tmp
/dev/mapper/LVMGroup-var           2743   439      2146  17% /var
/dev/mapper/LVMGroup-var--log      3674   157      3311   5% /var/log
```

## How `awk` Works

Consider the following:

```
pram=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')
```

Output will be:

```
         total   used   free   shared   buff/cache   available
Mem:     8000    3000   2000   500      2000         4500
```

**Breaking Down the `awk` Command**:

- **`awk`**: Invokes the `awk` tool to process text line by line.

- **`'$1 == "Mem:" {printf("%.2f"), $3/$2*100}'`**:
  - **`$1 == "Mem:"`**: This is a pattern matching condition. `$1` refers to the first field of each line (fields are typically separated by whitespace). This condition checks if the first field of the line is "Mem:".
  
  Filter will be:
  ```
  Mem:     8000    3000   2000   500      2000         4500
  ```

  - **`{printf("%.2f"), $3/$2*100}`**:
    - **`{}`**: Contains the actions to perform on lines that match the condition.
    - **`printf("%.2f")`**: Formats the output to two decimal places.
    - **`$3`**: Refers to the third field of the line, which is the "used" memory.
    - **`$2`**: Refers to the second field, which is the "total" memory.
    - **`$3/$2*100`**: Calculates the percentage of used memory by dividing used memory by total memory and then multiplying by 100.

# Sample Outputs Before Text Processing

### 1. **Arch**

```bash
$ uname -a
Linux myhost 5.4.0-80-generic #1 SMP Thu May 13 14:53:03 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
```

### 2. **Physical CPU**

```bash
$ grep "physical id" /proc/cpuinfo
physical id	: 0
physical id	: 0
physical id	: 1
physical id	: 1
```

### 3. **Virtual CPU**

```bash
$ grep "processor" /proc/cpuinfo
processor	: 0
processor	: 1
processor	: 2
processor	: 3
processor	: 4
processor	: 5
processor	: 6
processor	: 7
```

### 4. **RAM Usage**

#### Total RAM

```bash
$ free --mega
              total        used        free      shared  buff/cache   available
Mem:          8000         3000         2000         500         2000         4500
Swap:         2000          500         1500
```

#### Used RAM

```bash
$ free --mega
              total        used        free      shared  buff/cache   available
Mem:          8000         3000         2000         500         2000         4500
```

#### RAM Usage Percentage

```bash
$ free --mega
              total        used        free      shared  buff/cache   available
Mem:          8000         3000         2000         500         2000         4500
```

### 5. **Disk Usage**

#### Total Disk Space

```bash
$ df -m
Filesystem     1M-blocks  Used Available Use% Mounted on
/dev/sda1        102400  20480   71680  22% /
/dev/sdb1        204800  40960  163840  20% /data
```

#### Used Disk Space

```bash
$ df -m
Filesystem     1M-blocks  Used Available Use% Mounted on
/dev/sda1        102400  20480   71680  22% /
/dev/sdb1        204800  40960  163840  20% /data
```

#### Disk Usage Percentage

```bash
$ df -m
Filesystem     1M-blocks  Used Available Use% Mounted on
/dev/sda1        102400  20480   71680  22% /
/dev/sdb1        204800  40960  163840  20% /data
```

### 6. **CPU Load**

#### Idle CPU Percentage

```bash
$ vmstat 1 2
procs -----------memory---------- ---swap-- -----io---- --system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy id wa st
 1  0      0 200000  10000 50000    0    0     0     0    10    20  1  1 98  0  0
 0  0      0 200000  10000 50000    0    0     0     0    10    20  0  0 99  0  0
```

### 7. **Last Boot**

```bash
$ who -b
system boot  2024-07-23 09:30
```

### 8. **LVM Use**

```bash
$ lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda    8:0    0  100G  0 disk 
├─sda1 8:1    0  100G  0 part /
```

### 9. **TCP Connections**

```bash
$ ss -ta
State      Recv-Q Send-Q Local Address:Port Peer Address:Port
ESTAB      0      0      192.168.1.100:22  192.168.1.101:54321
LISTEN     0      128    0.0.0.0:80         0.0.0.0:*
ESTAB      0      0      192.168.1.100:80  192.168.1.102:54322
```

### 10. **User Log**

```bash
$ users
user1 user2 user3
```

### 11. **Network**

#### IP Address

```bash
$ hostname -I
192.168.1.100
```

#### MAC Address

```bash
$ ip link
...
link/ether 08:00:27:3a:15:4d brd ff:ff:ff:ff:ff:ff
...
```

### 12. **Sudo Log**

```bash
$ journalctl _COMM=sudo
Jul 24 10:20:10 myhost sudo[1234]: COMMAND=/usr/bin/apt update
Jul 24 10:21:45 myhost sudo[1235]: COMMAND=/usr/bin/apt upgrade
```
