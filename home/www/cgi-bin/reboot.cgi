#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html><head><title>Reboot Server"
echo "</title></head><body>"

echo "<h1>Rebooting Server Now</h1>"
echo "This page will redirect in 45 seconds..."
echo "Please wait..."
echo "<meta http-equiv=\"refresh\" content=\"45;url=http://jaycee5585.no-ip.org/\" />"
echo "</body></html>"
sudo reboot
