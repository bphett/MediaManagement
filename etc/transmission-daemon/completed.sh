#!/bin/sh
# script to check for complete torrents in transmission folder, then stop and move them
# either hard-code the MOVEDIR variable here…
MOVEDIR=/media/MediaServer/MediaServerFiles/CompletedTorrents # the folder to move completed downloads to
# …or set MOVEDIR using the first command-line argument
# MOVEDIR=%1
DELDIR=/media/MediaServer/MediaServerFiles/Delete

# logs all output to log file
LOGFILE=/media/MediaServer/MediaServerFiles/Logs/transmission-log.txt # the log file to use
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>$LOGFILE 2>&1 # everything below this line will be logged
# echo 'Logging Started ... '

# use transmission-remote to get torrent list from transmission-remote list
# use sed to delete first / last line of output, and remove leading spaces
# use cut to get first field from each line
TORRENTLIST=$(transmission-remote --auth=transmission:transmission --list | sed -e '1d;$d;s/^ *//' | cut --only-delimited --delimiter=' ' --fields=1)
echo ' ***** TORRENT LIST is '
echo $TORRENTLIST
echo ' *****     '
# for each torrent in the list
for TORRENTID in $TORRENTLIST
do
  TORRENTID=$(echo $TORRENTID | sed 's:*::')
  # removes asterisk * from torrent ID# which had error associated with it
  echo "***** Operations on torrent ID $TORRENTID starting. *****  "
  # check if torrent download is completed
  DL_COMPLETED=$(transmission-remote --auth=transmission:transmission --torrent $TORRENTID --info | grep "Percent Done: 100%")
  echo "DL_COMPLETED is $DL_COMPLETED"
  # check torrent’s current state is “Stopped”, “Finished”, or “Idle”
  STATE_STOPPED=$(transmission-remote --auth=transmission:transmission --torrent $TORRENTID --info | grep "State: Finished")
  echo "STATE_STOPPED is $STATE_STOPPED"
  # check if state is "Seeding"
  RATIO=$(transmission-remote --auth=transmission:transmission --torrent $TORRENTID --info | grep "Ratio:" | sed 's/  Ratio: //' | printf "%.0f\n" )
  echo "RATIO is $RATIO"
  LOCATION=$(transmission-remote --auth=transmission:transmission --torrent $TORRENTID --info | grep "Location:" )
  echo "LOCATION is $LOCATION"

  # if the torrent is “Finished” after downloading 100%…
  if [ "$DL_COMPLETED" = "  Percent Done: 100%" ] && [ "$LOCATION" = "  Location: /media/MediaServer/MediaServerFiles/ActiveTorrents" ]; then
    # copy files to post-proc directory if done downloading
    echo 'Moving files to completed directory. '
    transmission-remote 9091 --auth=transmission:transmission --torrent $TORRENTID --move $MOVEDIR
  else
    if [ "$DL_COMPLETED" = "  Percent Done: 100%" ] && [ "$STATE_STOPPED" = "  State: Finished" ]; then
      # move the files and remove the torrent from Transmission
      echo "Torrent #$TORRENTID is completed. "
      echo "Moving downloaded files to be deleted. "
      # echo " Deldir is #$DELDIR. "
      # echo " Torrent ID is #$TORRENTID"
      transmission-remote --auth=transmission:transmission --torrent $TORRENTID --move $DELDIR
      echo " Removing torrent from list. "
      transmission-remote --auth=transmission:transmission --torrent $TORRENTID --remove
      # delete files
      rm -rf /media/MediaServer/MediaServerFiles/Delete/*
    else
      echo "Torrent #$TORRENTID is not completed. Ignoring. "
    fi
  fi
  echo "***** Operations on torrent ID $TORRENTID completed. *****     "
  filebot -script fn:amc --output "/media/MediaServer/NewFiles" --log-file '/media/MediaServer/MediaServerFiles/Logs/amc-log.txt' --action copy -non-strict "/media/MediaServer/MediaServerFiles/CompletedTorrents" --def excludeList='/media/MediaServer/MediaServerFiles/Logs/amcexcludes.txt' subtitles=en "seriesFormat=/media/MediaServer/NewFiles/{n} ({y})/{'Season '+s}/{n} - {s00e00} - {t}"
done
