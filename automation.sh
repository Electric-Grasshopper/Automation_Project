#!/bin/bash

# Author: Mohit Gupta
# Email: mohit.gupta2jly@gmail.com
# GitHub: Electric-Grasshopper

timestamp=$(date '+%d%m%Y-%H%M%S')
myname="mohit"
s3_bucket="upgrad-electric-grasshopper/logs"

sudo apt update -y
sudo apt install apache2 -y
# check if Apache2 is running or not...
# Instasll Apache2 if not instaslled...
if [ $? -eq 0 ]
then
    echo "Apache2 is installed. Skipping Apache2 installation."
else
    echo "Apache2 is not installed. Installing"
    sudo apt install apache2 -y &> /dev/null
fi

# Check if the Apache service is running or not...
if [ `service apache2 status | grep running | wc -l` == 1 ]
then
	echo "Apache2 is running"
else
	echo "Apache2 is not running"
	echo "Starting apache2"
	sudo service apache2 start 
fi

# Check if the Apache service is enabled or not...
if [ `service apache2 status | grep enabled | wc -l` == 1 ]
then
	echo "Apache2 is enabled"
else
	echo "Apache2 is not enabled"
	echo "Enabling apache2"
	sudo systemctl enable apache2
fi

# Create archive of Apache2 log files...
echo "Compressing logs and storing into /tmp"

cd /var/log/apache2/

tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar *.log

echo "Copying logs to s3"

# Put logs in the S3 bucket...
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

if [ -e /var/www/html/inventory.html ]
then
    echo "Inventory exists"
else
    touch /var/www/html/inventory.html
    echo "<b>Log Type &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Date Created &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Type &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Size</b>" >> /var/www/html/inventory.html
fi

echo "<br>httpd-logs &nbsp;&nbsp;&nbsp;&nbsp; ${timestamp} &nbsp;&nbsp;&nbsp;&nbsp; tar &nbsp;&nbsp;&nbsp;&nbsp; `du -h /tmp/${myname}-httpd-logs-${timestamp}.tar | awk '{print $1}'`" >> /var/www/html/inventory.html

if [ -e /etc/cron.d/automation ]
then
    echo "Cron job exists"
else
    touch /etc/cron.d/automation
    echo "0 0 * * * root /root/Automation_Project/automation.sh" > /etc/cron.d/automation
    echo "Cron job added"
fi