#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "<html><head><title>New Files"
echo "</title></head><body>"
[ "$(ls -A /media/MediaServer/NewFiles)" ] && echo "<h1>New Media Files Are Awaiting Review</h1>" || echo "<h1>No New Media Files</h1>"
echo "</body></html>"
