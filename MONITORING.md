# Monitoring Explained

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
