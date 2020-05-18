#!/bin/bash
### README: Dump HDD, SSD temperatures on remote FreeNAS hosts from a Linux machine. 
### This script SCPs this script to remote freenas host, runs it, and collects output. 
HOSTS_FILE="/etc/hddtemps.hosts"

function die() { printf "$1\n"; exit 1; }
function usage() { 
IFS=$", "
printf "\nUsage:
    $0 -r [<host>]            # Show HDD (spinning rust)
    $0 -s [<host>]            # Show SSD
    If <host> is missing, the script is executed on every host (one per line) from $HOSTS_FILE
    This host must be able to SSH/SCP to the hosts in $HOSTS_FILE
\n"
exit 0;
}

hdd=0
ssd=0
if [[ "$1" == "-r" ]]; then
    hdd=1
elif [[ "$1" == "-s" ]]; then
    ssd=1
else
    echo "No option specified" && usage
fi

function runOnHost() {
    # Input: $1 = First argument, $2 = host. Should be able to 'ssh $1' without password. 
    # SCP this script to host and run it there. 
    host=$2
    scriptname=$(basename "$0")
    scpout=$(scp -q $0 $host:/tmp/)
    if [ $? -ne 0 ]; then
        ans="Error: SCP returned non-zero: $scpout\n"
    else
        sshout=$(ssh "$host" "/tmp/$scriptname $1 $host")
        ans="$sshout\n"
    fi
    ssh "$host" "rm /tmp/$scriptname"
    echo -e "$ans"
}

function getHDDInfo() {
    # Returns output if host is FreeBSD and matches hostname (the first component if a TLD)
    count=0
    camcontrol devlist | 
    while read l
    do
        pass_dev=`echo "$l" | sed 's@.*(\(.*\))@\1@g'`
        device=`echo $pass_dev | sed 's@,*pass[0-9]*,*@@g'`
        if [ -z $device ]; then
            continue
        fi
        if [[ $device == cd* ]]; then
            continue
        fi
        identify=`camcontrol identify $device 2>&1`
        if [ $? -ne 0 ]; then
            continue
        fi
        rpm=`echo "$identify" | grep "media RPM" | sed 's@media RPM *\(.*\)@\1@g'`
        if [ "$rpm" == "non-rotating" ]; then
            rpm="SSD"
        else 
            rpm="$rpm RPM"
        fi
        if [ "$rpm" == "SSD" -a "$ssd" -eq 0 ]; then
            continue
        fi
        if [ "$rpm" != "SSD" -a "$hdd" -eq 0 ]; then
            continue
        fi
        model=`echo "$identify" | grep "device model" | sed 's@device\ model\ *\(.*\)@\1@g'`
        serial_number=`echo "$identify" | grep "serial number" | sed 's@serial number *\(.*\)@\1@g'`
        smart=`smartctl --all /dev/$device`
        temp_line=`echo "$smart" | grep 194 | grep -i temperature`
        if [ -z "$temp_line" ]; then
            temp_line=`echo "$smart" | grep 190 | grep -i temperature`
        fi
        temp=`echo $temp_line | awk '{print $10}'`

        # $temp should be a number
        number_re='^[0-9]+$'
        if ! [[ $temp =~ $number_re ]] ; then
            temp="NaN $temp"
        fi
        count=$((count + 1))
        echo -e "$count." '@' "$device" '@' "$model" '@' "$serial_number" '@' "$rpm" '@' "$temp celsius"
    done | column -t -s '@'
}

# If this is a FreeBSD system, and $2 is $(hostname) run getHDDInfo
if [[ $(uname) == "FreeBSD" ]]; then
    first_component=$(echo "$(hostname)" | cut -d"." -f1)
    if [[ "$2" == $(hostname) ]] || [[ "$2" == "$first_component" ]]; then
        getHDDInfo
        exit 0
    fi
else # SSH only from Linux hosts.
    all_hosts=0
    if [[ -z "$2" ]]; then
        if [[ ! -f "$HOSTS_FILE" ]]; then
            echo "Config file ($HOSTS_FILE) not found." && usage
        fi
        readarray -t ALL_HOSTS < "$HOSTS_FILE"
        for host in "${ALL_HOSTS[@]}"
        do
            echo -e "Running on $host ... "
            runOnHost "$1" "$host"
        done
    else
        host="$2"
        echo -e "Running on $host ... "
        runOnHost "$1" "$host"
    fi
fi
