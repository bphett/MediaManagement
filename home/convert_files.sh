#!/bin/sh
# This script converts all media files on the server to mp4.

rm -rf /media/MediaServer/NewFiles/Temp

moviedir="/media/MediaServer/Movies"
tvdir="/media/MediaServer/TV Shows"
runscript="/home/mp4_automator/manual.py"
logfile="/media/MediaServer/MediaServerFiles/Logs/convertlog.txt"
fileslist=/media/MediaServer/NewFiles/Temp/fileslist.txt
mkdir -p /media/MediaServer/NewFiles/Temp
echo "::" > $fileslist

echo -e "\r" >> $logfile
echo "Starting run..." >> $logfile

IFSold=$IFS

#TV Shows section
echo -e "\r" >> $logfile
find '/media/MediaServer/TV Shows' -name '*.mkv' -printf '%p::' >> $fileslist
find '/media/MediaServer/TV Shows' -name '*.avi' -printf '%p::' >> $fileslist
find '/media/MediaServer/TV Shows' -name '*.wma' -printf '%p::' >> $fileslist
files=$(cat "$fileslist")

IFS=$'::'

for file in $files; do
echo "\r" >> $logfile
filename=$(basename "$file")
filepath=$(echo $file | sed "s/\/$filename//")
$runscript -i $file -m $filepath -a >> $logfile
done

IFS=$IFSold

#Movies section
rm -rf $fileslist
echo "::" > $fileslist
echo -e "\r" >> $logfile
find '/media/MediaServer/Movies' -name '*.mkv' -printf '%p::' >> $fileslist
find '/media/MediaServer/Movies' -name '*.avi' -printf '%p::' >> $fileslist
find '/media/MediaServer/Movies' -name '*.wma' -printf '%p::' >> $fileslist
files=$(cat "$fileslist")

IFS=$'::'

for file in $files; do
echo "\r" >> $logfile
filename=$(basename "$file")
filepath=$(echo $file | sed "s/\/$filename//")
$runscript -i $file -m $filepath -a >> $logfile
done

IFS=$IFSold

#Test Lines
#$runscript -i '/media/MediaServer/Test/testfile.mkv' -m '/media/MediaServer/Test/Result' -nd -a >> /media/MediaServer/Test/testlog.txt

#Post Stuff
echo -e "\r" >> $logfile
echo "Run completed." >> $logfile
echo -e "\r:" >> $logfile

rm -rf /media/MediaServer/NewFiles/Temp

# Initiate Post Processing
#sudo /etc/cron.hourly/postproc
