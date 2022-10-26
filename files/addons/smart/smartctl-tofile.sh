#!/bin/bash

# This is kind of a weird hack to get proper SMART readings on servers
# with drives that take a REALLY long time to publish their data to
# smartctl. It basically just outputs all of the data from smartctl
# to a file and then the Zabbix UserParam does a simple read of the file instead of 
# calling smartctl every time.
#
# Recommended to put this on a 45 minute cron job when combined with the zabbix template.
mkdir /etc/zabbix/scripts/smartctl-tofile
cd /etc/zabbix/scripts/smartctl-tofile
rm -f /etc/zabbix/scripts/smartctl-tofile/*smart.txt

# iterate over all devs
for drive in /dev/sd[a-z] /dev/sd[a-z][a-z]
do
   # if the dev doesn't exist, skip
   if [[ ! -e $drive ]]; then continue ; fi
   echo $drive

   # run the full smartctl info gathering on the disk
   smart=$(sudo /usr/sbin/smartctl -i -H -A -l error -l background $drive 2>&1)
   
   # output the data into a txt file
   echo "$smart" | tee /etc/zabbix/scripts/smartctl-tofile/${drive: -3}-smart.txt
done
