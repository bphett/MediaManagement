#!/bin/sh
# This script converts all media files on the server to mp4.

rm -rf /media/MediaServer/NewFiles/Temp

moviedir="/media/MediaServer/Movies"
tvdir="/media/MediaServer/TV Shows"
transcodedir="/media/MediaServer/Transcode"
runscript="/home/mp4_automator/manual.py"
logfile="/media/MediaServer/MediaServerFiles/Logs/convertlog.txt"
fileslist=/media/MediaServer/NewFiles/Temp/fileslist.txt
runningfile="/media/MediaServer/MediaServerFiles/transcoding.txt"
mkdir -p /media/MediaServer/NewFiles/Temp
echo "::" > $fileslist

echo -e "\r" >> $logfile
echo "Starting run..." >> $logfile

IFSold=$IFS

#TV Shows section
echo -e "\r" >> $logfile
find '/media/MediaServer/Transcode' -name '*.mkv' -printf '%p::' >> $fileslist
find '/media/MediaServer/Transcode' -name '*.avi' -printf '%p::' >> $fileslist
find '/media/MediaServer/Transcode' -name '*.wma' -printf '%p::' >> $fileslist
find '/media/MediaServer/Transcode' -name '*.mp4' -printf '%p::' >> $fileslist
files=$(cat "$fileslist")
#echo "files=$files"
echo ""

IFS=$'::'

if [ ! -e "$runningfile" ]; then
echo "Transcoding" > $runningfile

movepath="/media/MediaServer/NewFiles/Shows"
$runscript -i $tvdir -m $movepath

movepath="/media/MediaServer/NewFiles/Movies"
$runscript -i $transcodedir -m $movepath

rm -f $runningfile
fi

#for file in $files; do
#if [ -z "$file" ]; then
#   continue
#fi
#echo "\r" >> $logfile
#filename=$(basename "$file")
#filepath=$(echo $file | sed "s/\/$filename//")
#movepath="/media/MediaServer/NewFiles/Shows"
#echo "file=$file"
##echo "filepath=$filepath"
#echo $runscript
#$runscript -i $tvdir -m $movepath
## >> $logfile
#done

IFS=$IFSold

#Movies section
#rm -rf $fileslist
#echo "::" > $fileslist
#echo -e "\r" >> $logfile
#find '/media/MediaServer/Movies' -name '*.mkv' -printf '%p::' >> $fileslist
#find '/media/MediaServer/Movies' -name '*.avi' -printf '%p::' >> $fileslist
#find '/media/MediaServer/Movies' -name '*.wma' -printf '%p::' >> $fileslist
#files=$(cat "$fileslist")

#IFS=$'::'

#for file in $files; do

#echo "\r" >> $logfile
#filename=$(basename "$file")
#filepath=$(echo $file | sed "s/\/$filename//")
#$runscript -i $file -m $filepath -a >> $logfile
#done

#IFS=$IFSold

#Test Lines
#$runscript -i '/media/MediaServer/Test/testfile.mkv' -m '/media/MediaServer/Test/Result' -nd -a >> /media/MediaServer/Test/testlog.txt

#Post Stuff
echo -e "\r" >> $logfile
echo "Run completed." >> $logfile
echo -e "\r:" >> $logfile

rm -rf /media/MediaServer/NewFiles/Temp

# Initiate Post Processing
#sudo /etc/cron.hourly/postproc
