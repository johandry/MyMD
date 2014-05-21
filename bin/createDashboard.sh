#!/bin/bash

help() {
cat <<EOHELP
${0##*/} is used to create the database in different formats for the My Movies Dashboard application

The formats are: JSON, CSV, HTML and DB in SQLite. If ${0##*/} is executed without option by default will create all the formats
To create a new format it have to be included in ${0##*/} and in the myMD_format.sh script. You can clone it from other myMD_format.sh script.

Options:
  --all:  Create all the formats
  --json: Create the JSON format
  --csv:  Create the CSV format
  --html: Create the HTML format
  --db:   Create the DB format for SQLite

Examples:
  ${0##*/}              # Create all the formats
  ${0##*/} --all        # Same as previous example
  ${0##*/} --json       # Creates only the JSON file
  ${0##*/} --json --db  # Creates the JSON file and the SQLite DB file
EOHELP
exit 0
}
[[ ${1} == "-h" ]] && help

error() {
  echo -e "\033[1;91mERROR\033[0m:${1}" >&2
  exit 1
}

# Read configuration variables from myMD.conf located at the same directory as this script
[[ ! -e ${0%/*}/myMD.conf ]] && error "Configuration file not found at ${0%/*}/myMD.conf"
source ${0%/*}/myMD.conf

# Validate the variables from configuration file
err_msg=''
[[ ! -e ${SOURCE} ]]   && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Source directory does not exists (${SOURCE:-NULL})"
[[ ! -e ${BKPSRC} ]]   && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Backup directory does not exists (${BKPSRC:-NULL})"
[[ ! -e ${DSB_HOME} ]] && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Dashboard Home directory does not exists (${DSB_HOME:-NULL})"
[[ ! -e ${DSB_DRPB} ]] && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Dashboard Dropbox directory does not exists (${DSB_DRPB:-NULL})"
[[ ! -e ${SUBLER} ]]   && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Subler CLI is not installed (${SUBLER:-NULL})"
[[ ! -e ${mp4art} ]]   && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Mp4art is not installed (${mp4art:-NULL})"
[[ ! -e ${convert} ]]  && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m ImageMagick is not installed (${convert:-NULL})"
[[ -n ${err_msg} ]] && error ${err_msg}

# Check parameters and set _FORMAT_ to 1 if that format is required
# If no parameters or --all will create all the formats 
if [[ $# -eq 0 ]] || [[ ${1} == "--all" ]]
then 
  _JSON_=1; 
  _CSV_=1; 
  _HTML_=1; 
  _DB_=1;
  shift;
else
  while [[ $# -gt 0 ]]
  do
    [[ ${1} == "--json" ]] && _JSON_=1
    [[ ${1} == "--csv"  ]] && _CSV_=1
    [[ ${1} == "--html" ]] && _HTML_=1
    [[ ${1} == "--db"   ]] && _DB_=1
    shift;
  done
fi

# Check if the file for that format exists and load it
[[ -e ${0%/*}/myMD_json.sh ]] && [[ ${_JSON_} -eq 1 ]] && JSON=1 && source ${0%/*}/myMD_json.sh
[[ -e ${0%/*}/myMD_csv.sh  ]] && [[ ${_CSV_}  -eq 1 ]] && CSV=1  && source ${0%/*}/myMD_csv.sh
[[ -e ${0%/*}/myMD_html.sh ]] && [[ ${_HTML_} -eq 1 ]] && HTML=1 && source ${0%/*}/myMD_html.sh
[[ -e ${0%/*}/myMD_db.sh   ]] && [[ ${_DB_}   -eq 1 ]] && DB=1   && source ${0%/*}/myMD_db.sh


# Headers for each format
headers () {
  [[ ${JSON} -eq 1 ]] && json.header
  [[ ${CSV}  -eq 1 ]] && csv.header
  [[ ${HTML} -eq 1 ]] && html.header
  [[ ${DB}   -eq 1 ]] && db.header
}

# Footers for each format
footers () {
  [[ ${JSON} -eq 1 ]] && json.footer
  [[ ${CSV}  -eq 1 ]] && csv.footer
  [[ ${HTML} -eq 1 ]] && html.footer
  [[ ${DB}   -eq 1 ]] && db.footer
}

entry () {
  local ID=$(echo "$1" | tr '"' "'")
  local filename=$(echo "$2" | tr '"' "'")
  local ok_format=$(echo "$3" | tr '"' "'")
  local ok_backup=$(echo "$4" | tr '"' "'")
  local name=$(echo "$5" | tr '"' "'")
  local artist=$(echo "$6" | tr '"' "'")
  local main_genre=$(echo "$7" | tr '"' "'")
  local genres=$(echo "$8" | tr '"' "'")
  local release_date=$(echo "$9" | tr '"' "'")
  local description=$(echo "${10}" | tr '"' "'")
  local rating=$(echo "${11}" | tr '"' "'")
  local studio=$(echo "${12}" | tr '"' "'")
  local director=$(echo "${13}" | tr '"' "'")
  local producers=$(echo "${14}" | tr '"' "'")
  local screenwriters=$(echo "${15}" | tr '"' "'")
  local media_kind=$(echo "${16}" | tr '"' "'")
  local path=$(echo "${17}" | tr '"' "'")
  local artworks=$(echo "${18}" | tr '"' "'")

  artworks=$(echo ${artworks} | sed "s#${DSB_HOME}/\.\./##g" | sed 's/ /%20/g')
  local artwork=${artworks%%:*}
  artworks=${artworks#*:}
  
  local hd=0
  [[ ${filename} =~ .*HD\).* ]] && hd=1

  local entries=(
    ${ID}
    "${name}"
    "${filename}"
    "${artwork}"
    "${artworks}"
    ${hd}
    ${ok_format}
    ${ok_backup}
    "${artist}"
    "${main_genre}"
    "${genres}"
    "${release_date}"
    "${description}"
    "${rating}"
    "${studio}"
    "${director}"
    "${producers}"
    "${screenwriters}"
    "${media_kind}"
    "${path}"
  )

  [[ ${JSON} -eq 1 ]] && json.entry "${entries[@]}"
  [[ ${CSV}  -eq 1 ]] && csv.entry  "${entries[@]}"
  [[ ${HTML} -eq 1 ]] && html.entry "${entries[@]}"
  [[ ${DB}   -eq 1 ]] && db.entry   "${entries[@]}"
}

headers
ID=1
while read movies
do
  ok_format=0
  ok_backup=0

  movie=${movies##*/}

  [[ ${movie##*.} == "m4v" ]] && ok_format=1
  [[ -n $(ls "${BKPSRC}"/*/* | grep "${movie}") ]] && ok_backup=1

  name=
  artist=
  genres=
  main_genre=
  release_date=
  description=
  rating=
  studio=
  cast=
  director=
  producers=
  screenwriters=
  media_kind=

  while read data
  do
    [[ ${data} =~ "Name:" ]]             && name=$(echo ${data} | sed 's/Name: //')
    [[ ${data} =~ "Artist:" ]]           && artist=$(echo ${data} | sed 's/Artist: //')
    [[ ${data} =~ "Comments:" ]]         && genres=$(echo ${data} | sed 's/Comments: //')
    [[ ${data} =~ "Genre:" ]]            && main_genre=$(echo ${data} | sed 's/Genre: //')
    [[ ${data} =~ "Release Date:" ]]     && release_date=$(echo ${data} | sed 's/Release Date: //')
    # Ignore the Description field. Most of the time is the same as Long Description
    [[ ${data} =~ "Long Description:" ]] && description=$(echo ${data} | sed 's/Long Description: //')
    [[ ${data} =~ "Rating:" ]]           && rating=$(echo ${data} | sed 's/Rating: //')
    [[ ${data} =~ "Studio:" ]]           && studio=$(echo ${data} | sed 's/Studio: //')
    # Ignore Cast field. It is the same as Artists
    [[ ${data} =~ "Director:" ]]         && director=$(echo ${data} | sed 's/Director: //')
    [[ ${data} =~ "Producers:" ]]        && producers=$(echo ${data} | sed 's/Producers: //')
    [[ ${data} =~ "Screenwriters:" ]]    && screenwriters=$(echo ${data} | sed 's/Screenwriters: //')
    [[ ${data} =~ "Media Kind:" ]]       && media_kind=$(echo ${data} | sed 's/Media Kind: //')
  done < <(${SUBLER} -source "${movies}" -listmetadata)

  # These values where taken from iTunes
  case "${media_kind}" in
    0)  media_kind="Movie" ;;
    1)  media_kind="Music" ;;
    2)  media_kind="Audiobook" ;;
    6)  media_kind="Music Video" ;;
    9)  media_kind="Movie" ;;
    10) media_kind="TV Show" ;;
    11) media_kind="Booklet" ;;
    14) media_kind="Ringtone" ;;
    *)  media_kind="UNKNOWN (${media_kind})" ;;
  esac

  # Get the movie artworks
  artworkDir=`printf "${DSB_ARTW}/%05d" $ID`
  
  mkdir -p "${artworkDir}"
  ln -s "${movies}" "${artworkDir}"
  ${mp4art} --extract "${artworkDir}/${movie}" &>/dev/null
  rm -f "${artworkDir}/${movie}"
  artworkPics=
  for p in "${artworkDir}/${movie%.*}".art*
  do
    ${convert} "${p}" -resize 100x140\> "${p}.tmp" 2>/dev/null
    [[ -e "${p}.tmp" ]] && mv "${p}.tmp" "${p}"
    if [[ -z ${artworkPics} ]]
      then
      artworkPics=${p}
    else
      artworkPics="${artworkPics}:${p}"
    fi
  done

  entry ${ID} "${movie}" ${ok_format} ${ok_backup} "${name}" "${artist}" "${main_genre}" "${genres}" "${release_date}" "${description}" "${rating}" "${studio}" "${director}" "${producers}" "${screenwriters}" "${media_kind}" "${movies}" "${artworkPics}"

  (( ID++ ))
done < <(ls "${SOURCE}"/*/*) 
# Replace above line for: 'done < <(ls "${SOURCE}"/*/* | head -5)' to test with the first 5 movies.
footers

# Copy the JSON, CSV and DB files to Dropbox
cp "${JSON_MOVIES}" "${DSB_DRPB}" 
cp "${CSV_MOVIES}" "${DSB_DRPB}"
cp "${DB_MOVIES}" "${DSB_DRPB}"

/usr/bin/osascript -e 'Display notification "Movies Dashboard have been created in your Site and exported to Dropbox" with title "Movies Dashboard"'
