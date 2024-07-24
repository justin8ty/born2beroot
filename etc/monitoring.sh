# Arch

arch=$(uname -a)

# Physical CPU

pcpu=$(grep "physical id" /proc/cpuinfo | wc -l)

# Virtual CPU

vcpu=$(grep "processor" /proc/cpuinfo | wc -l)

# RAM Usage

tram=$(free --mega | awk '$1 == "Mem:" {print $2}')
uram=$(free --mega | awk '$1 == "Mem:" {print $3}')
pram=$(free --mega | awk '$1 == "Mem:" {printf("%.2f"), $3/$2*100}')

# Disk Usage

tdisk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{td += $2} END {printf ("%.1fGb\n"), td/1024}')
udisk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{ud += $3} END {print ud}')
pdisk=$(df -m | grep "/dev/" | grep -v "/boot" | awk '{ud += $3} {td += $2} END {printf("%d"), ud/td*100}')

# CPU Load

cpuidle=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
cpucalc=$(expr 100 - $cpuidle)
cpul=$(printf "%.1f" $cpucalc)

# Last Boot

lboot=$(who -b | awk '$1 == "system" {print $3 " " $4}')

# LVM Use

lvmu=$(if [ $(lsblk | grep "lvm" | wc -l) -gt 0 ]; then echo yes; else echo no; fi)

# TCP Connections

tcpc=$(ss -ta | grep ESTAB | wc -l)

# User Log

ulog=$(users | wc -w)

# Network

ip=$(hostname -I)
mac=$(ip link | grep "link/ether" | awk '{print $2}')

# Sudo Log

ncmd=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# Display

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

