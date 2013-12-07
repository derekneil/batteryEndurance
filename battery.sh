#!/bin/bash
#track the battery life of macbookpro over time

function tryUpload () {

	#try to upload file contents to api
	baseURL='http://web.cs.dal.ca/~dneil/battery.php'
	key=apikey=`cat .batteryapikey`

	while read line           
	do           
	    url=${baseURL}\?entry=$line\&$key
	    response=$(curl --write-out %{http_code} --silent --output /dev/null $url )

	    #unsuccessfull, save back to another file
	    if [ "$response" != "200" ]; then
	    	echo $line >> .batteryHistoryNotUploaded
	    fi

	done < .batteryHistoryToUpload

	`rm .batteryHistoryToUpload`

	remaining=".batteryHistoryNotUploaded"
	if [ -e "$remaining" ]; then #if .batteryHistoryNotUploaded file exists
		`mv -f $remaining .batteryHistoryToUpload`
	fi
}

#schedule script to see if it should fully run
#cron every 30 minutes
# 0-59/30 * * * * ~/.battery.sh
date=`date +"20%y%m%d%H"`
cycle=`/usr/sbin/ioreg -w0 -l | grep \"CycleCount\" | cut -d " " -f19`
current=${date}\,${cycle}
last=".batteryScriptLastRun"
if [ ! -e "$last" ]; then #if last run time file doesn't exist
	#run script
	:
else 
	lastRun=`cat $last`
	IFS=',' read -ra lastRun <<< "$lastRun"
	newdate=`expr $date - 18` #must be at least X hours later to run based on time
	if [ "$newdate" -gt "${lastRun[0]}" ]; then #if last run time more than X hours ago
		#run script
		:
	elif [ "$cycle" -gt "${lastRun[1]}" ]; then #else if last cycle less than current cycle
		#run script
		:
	else
		remaining=".batteryHistoryToUpload"
		if [ -e "$remaining" ]; then #if .batteryHistoryNotUploaded file exists
			tryUpload
		fi
		exit 0
	fi
fi

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
entry=${entry}\,${cycle}\,`/usr/sbin/ioreg -w0 -l | grep \"DesignCycleCount  | cut -d " " -f19`

#save to file for batch processing if you haven't been online in a while
echo $entry >> .batteryHistoryToUpload

tryUpload

#save date and cycle to check on next run
echo $current > .batteryScriptLastRun

#check out your sweet graph on the server you put battery.php and the highcharts framework on!