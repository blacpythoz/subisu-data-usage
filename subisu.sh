#!/bin/bash

## Variables
username=""
password=""
fromDate=""
toDate=""
today=`date +%d`
monthAgo=`date +%Y-%m-%d -d "${today} day ago"`



## Get Input
getInput() {
echo -n "User name: "
read username
echo -n "Password: "
read password
echo -n "From Date(yyyy-mm-dd) "
echo "[Default: yesterday] "
read fromDate
    if [[ -z "$fromDate" ]]; then
        fromDate=`date +%Y-%m-%d -d "yesterday"`
    fi
echo -n "To Date (yyyy-mm-dd) : "
echo "[Default: Today]  "
read toDate
    if [[ -z "$toDate" ]]; then
        toDate=`date +%Y-%m-%d`
    fi
}

getAccess() {
    curl -s --cookie-jar /tmp/subisu "http://myaccount.subisu.net.np/userportal/newlogin.do?phone=0" --data "type=1&username=${username}&password=${password}" > debugLog
    checkInvalid=`grep "Access Denied" debugLog`
    if [[ -n $checkInvalid ]]
    then
        echo "Access Denied. Username/password is incorrect"
        exit 1
    fi
}


getInfo() {
        curl -s --cookie /tmp/subisu "http://myaccount.subisu.net.np/userportal/usageSummary.do" --data "pageTitle=Usage+Summary&fromdate=${fromDate}&todate=${toDate}&actid=${username}&period=last12hrs&submit=Go" --compressed > debug
    IFS=$'\n'

    # clean up the mess and add to array
    infos=(`cat debug | grep -A 5 "$username" | sed 's/<[^>]*>//g'`)

    unset IFS

    #printing
    echo -e "\n\n"
    echo "IP: ${infos[2]}"
    echo "Upload: ${infos[3]}"
    echo "Download: ${infos[4]}"
    echo "Total: ${infos[5]}"
    echo -e "\n\n"
}

getInput
getAccess
getInfo
