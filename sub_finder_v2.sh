#!/bin/bash
# Script Name: sub_finder.sh
# Version: 2.0
# Purpose: Find valid subdomains and their IP addresses from a target domain's HTML page.
# Author: Youssef Mouatta
# Example Usage: ./sub_finder.sh example.com
# Last Updated: 2024/12/16



if [ $# -ne 1 ];then
	echo "Exemple usage : $0 google.com"
	exit 1
fi

rm -f index.html
wget "$1" -O index.html 2>/dev/null

if [ ! -f index.html ]; then
    echo "Failed to download $1. Please check the URL."
    exit 1
fi

grep -Eo 'https?://[^"]+' index.html | grep "\.${1}" | grep -v "^www\.$1" | cut -d '/' -f3 | sort -u | cut -d ' ' -f1 | uniq -u > sub.txt

if [ ! -s sub.txt ]; then
    echo "No subdomains found for $1."
    exit 1
fi

for sub in $(cat sub.txt) ;do
    ping_output=$(ping -c 1 "$sub" 2>/dev/null)

	if [[ $? -eq 0 ]];then
		echo  "$sub is a Valid subdomain"
		ip_address=$(echo "$ping_output" | awk -F'[()]' '{print $2}')
	        echo "IP Address: $ip_address"
	else
		echo  "$sub is an Invalid subdomain"
	fi
	echo
done

