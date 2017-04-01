#!/bin/bash

## Global Variables
username="" 
password=""
fromDate=""
toDate=""
declare -a infos

## Get Input
getInput() {
echo -n "User name: "
read username
echo -n "Password: "
read password
}

## Custom date input 
customDateInput() {
echo -n "From Date(yyyy-mm-dd) "
echo "[Default: yesterday] "
read fromDate
    if [[ -z "$fromDate" ]]; then
        getTodayInfo
        exit 0
    fi
echo -n "To Date (yyyy-mm-dd) : "
echo "[Default: Today]  "
read toDate
    if [[ -z "$toDate" ]]; then
        getTodayInfo
        exit 0
    fi
}

## Login and cookie
getAccess() {
    curl -s --cookie-jar /tmp/subisu "http://myaccount.subisu.net.np/userportal/newlogin.do?phone=0"\
    	    --data "type=1&username=${username}&password=${password}" > debugLog
    checkInvalid=$(grep "Access Denied" debugLog)
    if [[ -n $checkInvalid ]]
    then
        echo "Access Denied. Username/password is incorrect"
        exit 1
    fi
}

## Extracts the informations
getInfo() {
    echo "$fromDate --- $toDate"
        curl -s --cookie /tmp/subisu "http://myaccount.subisu.net.np/userportal/usageSummary.do"\
	       	--data "pageTitle=Usage+Summary&fromdate=${fromDate}&todate=${toDate}&actid=${username}&period=last12hrs&submit=Go"\
	       	--compressed > debug
        ## Checks for session expiry
    checkInvalid=$(grep "Your Session has been expired" debugLog)

    IFS=$'\n'
    # clean up the mess and add to array
    infos=($(cat debug | grep -A 5 "$username" | sed 's/<[^>]*>//g'))
    unset IFS

}

## Get daily infos

getTodayInfo() {
        fromDate=$(date +%Y-%m-%d --date "yesterday")
        toDate=$(date +%Y-%m-%d)
        getInfo
        displayInfo
}

## Login and cookie
getAccess() {
    curl -s --cookie-jar /tmp/subisu "http://myaccount.subisu.net.np/userportal/newlogin.do?phone=0"\
    	    --data "type=1&username=${username}&password=${password}" > debugLog
    checkInvalid=$(grep "Access Denied" debugLog)
    if [[ -n $checkInvalid ]]
    then
        echo "Access Denied. Username/password is incorrect"
        exit 1
    fi
}

getThisMonthInfo() {
     fromDate=$(date --date "-$(date +%d) days -0 month" +%Y-%m-%d)
     toDate=$(date +%Y-%m-%d)
     getInfo
     displayInfo
 }


## Get the monthly infos
getMonthlyInfo() {
    #declare -a activationDate
    #IFS=$'\n'
    #activationDate=$(curl -s --cookie /tmp/subisu "http://myaccount.subisu.net.np/userportal/home.do?from=Home" --compressed | grep -A 5 "$username" | sed 's/<[^>]*>//g' )
    #curl -s --cookie /tmp/subisu "http://myaccount.subisu.net.np/userportal/home.do?from=Home" --compressed | grep -A 5 "$username" | sed 's/<[^>]*>//g' > monthly
    #echo "${activationDate}"
    #unset IFS

    for ((i=0;i<=$1;i++))
    do
        #First day of Last Month
        fromDate=$(date --date "-$((i+1)) month" +%Y-%m-01)
        #Last day of Last Month 
        toDate=$(date --date "-$(date +%d) days -$i month" +%Y-%m-%d)
        getInfo
        displayInfo
     done
}

getDailyInfo() {
    temp=$fromDate
    while [ "$d" != $toDate ]; do
      d=$(date -I --date "$d + 1 day")
    done
}

## Displays the infos
displayInfo() {
#    echo "IP: ${infos[2]}"
    echo "Upload: ${infos[3]}"
    echo "Download: ${infos[4]}"
    echo "Total: ${infos[5]}"
}

getInput
getAccess

#getThisMonthInfo

#customDateInput

getMonthlyInfo 5
#getInfo
#displayInfo
