![SCREENSHOTS](https://raw.github.com/derekneil/batteryEndurance/master/battery.png "Battery Graph")

##Local
Place the battery script in your ~/ home dir.
Make sure the file has execute persmissions so it can run.
```
chmod 700 battery.sh
```

In the same directory, create a file containing some random string to use as your private api key.
```
echo somerandomstringhere > .batteryapikey
chmod 400 .batteryapikey
```

Schedule a cron job to run it if you want (this example runs every half hour).
```
echo "0-59/30 * * * * ~/.battery.sh" >> ~/.crontab
crontab ~/.crontab
```

##Server
Place a copy of your apikey on the web server, and again, make sure only you have read permissions.
```
chmod 400 .batteryapikey
```

Place the battery.php on your web server, and set permissions appropriately.
```
chmod 600 battery.php
```
The php script will create the support files it needs for storing data.