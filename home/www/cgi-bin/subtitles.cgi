#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html><head><title>Updating Subtitles..."
echo "</title></head><body>"

echo "<h1>Updating Missing Subtitles...</h1>"

echo "This page will redirect automatically..."
echo "Please wait..."
echo "<meta http-equiv=\"refresh\" content=\"10;url=http://jaycee5585.no-ip.org/\" />"
echo "</body></html>"
sudo reboot

echo "</body></html>"

sudo /etc/cron.hourly/findsubtitles
