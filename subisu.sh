#!/bin/bash

username=""
password=""

fromDate="2017-03-28"
toDate="2017-03-30"

echo -n "User name: "
read username
echo -n "Password: "
read password
echo -n "From Date[yyyy-mm-dd]: "
read fromDate
echo -n "To Date [yyyy-mm-dd] : "
read toDate
curl -s --cookie-jar /tmp/subisu "http://myaccount.subisu.net.np/userportal/newlogin.do?phone=0" --data "type=1&username=${username}&password=${password}" > debugLog
checkInvalid=`grep "Access Denied" debugLog`
    if [[ -n $checkInvalid ]]
    then
        echo "Access Denied"
    else
        curl -s --cookie /tmp/subisu "http://myaccount.subisu.net.np/userportal/usageSummary.do" --data "pageTitle=Usage+Summary&fromdate=${fromDate}&todate=${toDate}&actid=${username}&period=last12hrs&submit=Go" --compressed > debug
    IFS=$'\n'

    # clean up the mess and add to array
    infos=(`cat debug | grep -A 5 "subasha99" | sed 's/<[^>]*>//g'`)

    unset IFS

    #printing
    echo "IP: ${infos[2]}"
    echo "Upload: ${infos[3]}"
    echo "Download: ${infos[4]}"
    echo "Total: ${infos[5]}"
fi
