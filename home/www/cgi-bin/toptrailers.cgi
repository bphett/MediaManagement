#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html><head><title>New Files"
echo "</title></head><body>"
/etc/cron.weekly/fetchtoptrailers
echo "<h1>Updating Top Trailers...</h1>"

echo "This page will redirect in 10 seconds..."
echo "Please wait..."
echo "<meta http-equiv=\"refresh\" content=\"10;url=http://jaycee5585.no-ip.org/\" />"


echo "</body></html>"
