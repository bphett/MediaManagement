#!/bin/bash
# downloads all missing trailers - it goes through all your movies and matchs them up with an entry
# in plex, grabs the imdb id from plex, and then parses the trailer url from the imdb site, then passes
# that to youtube-dl to download the trailer, it skips entries that dont have a matching imdb entry 
# or if the trailer already exists
# must have 'sqlite3' and 'youtube-dl' packages (apt-get install sqlite3 youtube-dl)
# set 'mpath' and 'pms' accordingly

# Variables
echo "setting variables"
export mpath="$2";
if mpath=""; then mpath="/media/MediaServer/Trailers/"; fi
if [ "$1" == "All" ]; then mpath="/media/MediaServer/Movies/"; fi
if [ "$1" == "ALL" ]; then mpath="/media/MediaServer/Movies/"; fi
export pms="/media/MediaServer/MediaServerFiles/PlexData/Plex Media Server/"; \
export imdb="http://www.imdb.com/"; \
export agent='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:32.0) Gecko/20100101 Firefox/32.0'; \

# Functions
echo "Defining functions"
function guid_from_filename() { 
  sqlite3 "${pms}Plug-in Support/Databases/com.plexapp.plugins.library.db" \
   "select guid from media_parts, media_items, metadata_items where media_parts.media_item_id=media_items.id and  
   media_items.metadata_item_id=metadata_items.id and media_parts.file LIKE '%$1%';";
}
function dirhash_from_guid() { 
 echo -n "$1" | shasum | cut -d" " -f1 | sed -e 's/^\(.\{1\}\)/\1\//' -e 's/ .*//'; 
} 
function imdb_xml_from_guid() { 
 cat "${pms}Metadata/Movies/$(dirhash_from_guid "$1").bundle/Contents/com.plexapp.agents.imdb/Info.xml"; 
} 
function imdb_from_guid() { 
 imdb_xml_from_guid "$1" | grep 'Movie id' | cut -d\" -f2 |grep -v "^$"; 
} 
function imdb_video_from_imdb2() { 
 curl "${imdb}title/$1/?ref_=fn_al_tt_1" -s -A "${agent}" --referer "${imdb}" | \
 grep "title-trailer video-colorbox" | sed s#'^.*data-video="\(.*\)" data.*$'#'\1'#g; 
} 
function imdb_video_from_imdb() { 
 curl "${imdb}title/$1/?ref_=fn_al_tt_1" -s -A "${agent}" --referer "${imdb}" | \
 grep "tt_ov_vi" | sed 's/.*imdb\///' | sed 's/?ref_=tt_ov_vi".*//' | sed 's/<a href="\/video\/screenplay\///'
} 
IFS="
"; 

#Build File List
if [ "$mpath" != "/media/MediaServer/Trailers/" ]; then
echo -n "Building Movies List..."; files="$(find "${mpath}" -type f  |grep -vi -e "\-trailer\.*" \
-e "\.ass$" -e "\.srt$" -e "\.idx$" -e "\.sub$" -e "\.ssa$" -e "\.alt$" -e "\.smi$" -e "\.txt$" \
-e "\.nfo$" -e "\.jpg$" -e "\.png$" -e "\.db$" -e "\.jpeg$")"; echo done; 
echo -e "\r"
fi

#---------------------------------------------------------------

function get_trailer() { 
# Begin Processing

echo "Getting Movie Name"
if [ "$mpath" == "/media/MediaServer/Trailers/" ]; then
mname="$(wget -qO- $1 |
 perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)(?: - IMDB)?\s*<\/title/si')"
else
mname="$(echo "$justfile" | sed s/\.[^\.]*$//)"; 
fi
echo "input is $1"
echo "mname is $mname"

  if [ "$mpath" == "/media/MediaServer/Trailers/" ]; then
  cd $mpath
  else
  cd "$mpath$mname"
  fi
echo "Working directory is "
pwd

if [ "$mpath" == "/media/MediaServer/Trailers/" ]; then
    imdbi="$(echo ${1} | sed 's/http:\/\/www.imdb.com\/title\///')"
else
    #expression to get imdbi
#  echo -e "\r"
#  echo "Just File: $justfile"; 
#  echo -e "\r"
#  echo "Movie Name: $mname"; 
#  echo -e "\r"
  if [ ! -e "$(dirname "${filename}")/${mname}-trailer."* ]; then
#&& [ "$(grep "^${mname}$" ~/.no_trailers.txt)" = "" ]; then
    guid="$(guid_from_filename "${justfile}")";
    echo "Got GUID ${guid}"
    imdbi="$(imdb_from_guid "${guid}")"
#    [ -z "${guid}" ] && continue
  else
    echo "Trailer Exists."
  fi
fi

    echo "Got IMDB ID ${imdbi}"
    echo -e "\r"
#    [ -z "${imdbi}" ] && continue

    imdbv="$(imdb_video_from_imdb "${imdbi}")";
    #imdbv="vi2671553817"
    if [ -z "${imdbv}" ]
    then
        echo "First attempt at ID failed.. Trying again."
        imdbv="$(imdb_video_from_imdb2 "${imdbi}")";
    fi
    echo "Got IMDB Video ID ${imdbv}"
    echo -e "\r"
    if [ -z "${imdbv}" ]; then echo "${mname}" >> ~/.no_trailers.txt; continue; fi;
    imdb_url="${imdb}video/imdb/${imdbv}/";
    echo "Got Youtube URL $imdb_url"
    echo -e "\r"
#    echo "youtube-dl --output \"${mname}.%(ext)s\" \"${imdb_url}\"";
#    echo -e "\r"
    youtube-dl --output "${mname}-trailer.%(ext)s" "${imdb_url}";
#  else
#    echo "Already have trailer for ${mname} or there is none for it on IMDB";
#    echo -e "\r"
#  fi;
#done;

echo -n "Looking for .aspx files to rename...";
echo -e "\r"
rename="$(find "${mpath}" -type f -name "*.aspx")";
echo "done";
echo -e "\r"
if [ -z "${rename}" ]; then 
  echo "Nothing To Rename"
else
  echo "Renaming MPEG v4 .aspx files to .mp4   ";
  for filenamed in $(file ${rename} | grep 'MPEG v4' | sed s#"\-trailer.aspx.*$"#"-trailer"#g); do
    mv "${filenamed}.aspx" "${filenamed}.mp4"; 
  done;
  echo "done";
  echo "Renaming Macromedia Flash Video .aspx files to .flv   ";
  for filenamed in $(file ${rename} | grep 'Macromedia Flash Video' | sed s#"-trailer\.aspx.*$"#"-trailer"#g); do 
    mv "${filenamed}.aspx" "${filenamed}.flv"; 
  done;
  echo "done";
fi;
  echo "Copying files..."
  echo "mname = ${mname}"
  if [ -f ${mpath}${mname}-trailer.flv ]
  then
    if [ "$mpath" == "/media/MediaServer/Trailers/" ]; then
      mkdir "${mpath}${mname}"
      mv "${mpath}${mname}-trailer.flv" "${mpath}${mname}/${mname}-trailer.flv"
      cp "${mpath}${mname}/${mname}-trailer.flv" "${mpath}${mname}/${mname}.flv"
    fi
  fi
  if [ -f ${mname}-trailer.mp4 ]
  then
    if [ "$mpath" == "/media/MediaServer/Trailers/" ]; then
      mkdir "/media/MediaServer/Trailers/${mname}"
      mv "/media/MediaServer/Trailers/${mname}-trailer.mp4" "/media/MediaServer/Trailers/${mname}/${mname}-trailer.mp4"
      cp "/media/MediaServer/Trailers/${mname}/${mname}-trailer.mp4" "/media/MediaServer/Trailers/${mname}/${mname}.mp4"
    fi
  fi
} 
#----------------------------------------------------------------------

if [ "$mpath" == "/media/MediaServer/Trailers/" ]; then
get_trailer "$1"
else
for filename in $files; do
  echo "Working on $filename"
  echo -e "\r"
  justfile="$(basename "${filename}")"
  get_trailer "$justfile"
done
fi
