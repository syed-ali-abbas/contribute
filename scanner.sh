#!/bin/bash
ip=$1
echo $ip
#ip=10.10.10.198
## USAGE
## ./scanner.sh 10.10.10.198
mkdir nmapScan

sudo masscan -p1-65535 $ip --rate=1000 -e tun0 -vv 2>/tmp/error |tee `pwd`/nmapScan/Ports& 
PID=$! #simulate a long process

while true;
do
	# echo $(cat /tmp/error |grep -i "transmit thread #0 complete")
	complete=$(grep -i "transmit thread #0 complete" /tmp/error 2>/dev/null |wc -l)
	# echo $complete
	# if [ $complete == "1" ]
	if [ $complete == "1" ]
	then
		sleep 1
		# echo $complete
		break
	fi
done

rm /tmp/error
# complete=0
# kill -9 $PID
echo -e "Port Scan Saved in `pwd`/nmapScan/Ports"

ports=$(cat `pwd`/nmapScan/Ports | awk -F " " '{print $4}' | awk -F "/" '{print $1}' | sort -n | tr '\n' ',' | sed 's/,$//')

echo -e "\n---------------------------------------------"
echo -e "---------------------------------------------"
echo 	"         BASIC PORT SCAN (SV SC) "
echo -e "---------------------------------------------"
echo -e "---------------------------------------------\n"
nmap -T4 -sV -sC -p$ports $ip -oN nmapScan/basic_scan.txt

echo -e "Basic Port Scan Saved in `pwd`/nmapScan/basic_scan.txt"

echo -e "\n---------------------------------------------"
echo -e "---------------------------------------------"
echo 	" BASIC VULN SCAN (No Ping AND Script VULN) "
echo -e "---------------------------------------------"
echo -e "---------------------------------------------\n"

nmap -T4 -Pn -sV -sC --script=vuln -p$ports $ip -oN nmapScan/vuln_scan.txt

echo -e "Basic Vuln Scan Saved in `pwd`/nmapScan/vuln_scan.txt"
ports=0