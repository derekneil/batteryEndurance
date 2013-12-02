#!/bin/bash
#track the battery life of macbookpro over time


#if using this part of the script, schedule for every 5 minutes
#cron every 5 minutes
# 0-59/5 * * * * ~/.battery.sh
date=`date +"20%y%m%d%H"`
cycle=`/usr/sbin/ioreg -w0 -l | grep \"CycleCount\" | cut -d " " -f19`
current=${date}\,${cycle}
last=".batteryLastRun"
if [ ! -e "$last" ]; then #if last run time file doesn't exist
	#run script
	echo "run script lastRun file not found"
else 
	IFS=',' read -a lastRun <<< `cat $last`
	newdate=`expr $date-18`
	if [ "$newdate" -gt "$lastRun[0]" ]; then #if last run time more than X hours ago
		#run script
		echo "run script newer date found"
	elif [ "$cycle" -gt "$lastRun" ]; then #else if last cycle less than current cycle
		#run script
		echo "run script newer cycle found"
	else
		echo "exit"
		exit 0
	fi
fi


#schedule this script as a cron job twice a day
#aim for when the computer will be on, and you'll have internet
#cron 7:45am
# 45 7 * * * ~/.battery.sh

#cron 6:30pm
# 30 18 * * * ~/.battery.sh

#check for write permissions in current dir
#if ...
#return 1;

#collect battery info and store in tmp file
#you have to prune the data from ioreg
#    | |           "MaxCapacity" = 8667
#    | |           "CycleCount" = 5
#    | |           "DesignCapacity" = 8440
#    | |           "DesignCycleCount9C" = 1000
#it was just the first hit on google
# TODO: there might be a faster way to get this info
date=`date +"20%y,%m,%d,%H,%M"`
entry=${date}\,`/usr/sbin/ioreg -w0 -l | grep -E '\"MaxCapacity\"|\"DesignCapacity\"'  | cut -d " " -f19 | tr '\r\n' ',' | rev | cut -c 2- | rev`
entry=${entry}\,`/usr/sbin/ioreg -w0 -l | grep -E '\"CycleCount\"|\"DesignCycleCount'  | cut -d " " -f19 | tr '\r\n' ',' | rev | cut -c 2- | rev`


#save to file for batch processing if you haven't been online in a while
echo $entry >> .batteryHistoryToUpload

#try to upload file contents to api
baseURL='http://web.cs.dal.ca/~dneil/battery.php'
while read line           
do           
    url=${baseURL}\?entry=$line
    curl -s ${url} > /dev/null

    #unsuccessfull, save back to another file
    if [ ${?} == 1 ]; then
    	echo $line >> .batteryHistoryNotUploaded
    fi

done < .batteryHistoryToUpload

`rm .batteryHistoryToUpload`
`touch .batteryHistoryToUpload`

remaining=".batteryHistoryNotUploaded"
if [ -e "$remaining" ]; then #if .batteryHistoryNotUploaded file exists
	`mv .batteryHistoryNotUploaded .batteryHistoryToUpload`
fi

#make sure permissions are set correctly for file
`chmod 644 .batteryHistoryToUpload`

#save date and cycle to check on next run
echo $current > .batteryLastRun
echo "end script, saved current in batteryLastRun"
#check out your sweet graph on the server you put battery.php and the highcharts framework on!