#!/usr/bin/env bash
#set -x

VERSION='2.0.0'
TITLE='My Movies Dashboard'
PROJECT="MyMD"
SOURCE_DIR="server/bash"
# SOURCE=

#=======================================================================================================
# Author: Johandry Amador <johandry@gmail.com>
# Title:  {title}
# Version: {version}
#
# Usage: {script_name} <options>
#
# Options:
#     -h, --help     Display this help message. bash {script_name} -h
#     --version      Print {title} version
#     --update       Update to latest online version of {title} and create a backup of local copy.
#     --debug        Useful when {title} is in development
#     -a, --all      Create all the formats
#     --json         Create the JSON format
#     --csv          Create the CSV format
#     --html         Create the HTML format
#     --db           Create the DB format for SQLite
#     --chk-bkp      Check for movies backup
#
# Description: {title} is a script to create the database in different formats for the My Movies Dashboard application
#               The formats are: JSON, CSV, HTML and DB in SQLite. If ${0##*/} is executed without option by default will create all the formats
#               To create a new format it have to be included in ${0##*/} and in the myMD_format.sh script. You can clone it from other myMD_format.sh script.
#
# Examples:
#   ${script_name}              # Create all the formats
#   ${script_name} --all        # Same as previous example
#   ${script_name} --json       # Creates only the JSON file
#   ${script_name} --json --db  # Creates the JSON file and the SQLite DB file
#
# Report Issues or create Pull Requests in http://github.com/johandry/{project_name}
#=======================================================================================================

[[ ! -e "$HOME/bin/common.sh" ]] && \
  echo "~/bin/common.sh not found, install it with: " && \
  echo "    curl -s http://cs.johandry.com/install | bash" && \
  exit 1

source ~/bin/common.sh

TMP_MOVIES_LIST_FILE=$(mktemp /tmp/${SCRIPT_NAME}.movies.lst.XXXX) || \
  error "Cannot create temporal file for movie list" -ec 1
BAR_LENGTH=80
BAR_SPC=$(printf "%*s" ${BAR_LENGTH})
BAR_CHR=$(printf "%*s" ${BAR_LENGTH} | tr ' ' '=')

# Read configuration variables from myMD.conf located at the same directory as this script
[[ ! -e ${SCRIPT_DIR}/config ]] && \
  error "Configuration file not found at ${SCRIPT_DIR}/myMD.conf" -ec 1

source "${SCRIPT_DIR}/config"

CHK_BKP=0

validate () {
  # Validate the variables from configuration file
  err_msg=''
  [[ ! -e ${SOURCE} ]]   && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Source directory does not exists (${SOURCE:-NULL})"
  (( ${CHK_BKP} ))       && \
  [[ ! -e ${BKPSRC} ]]   && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Backup directory does not exists (${BKPSRC:-NULL})"
  [[ ! -e ${DSB_HOME} ]] && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Dashboard Home directory does not exists (${DSB_HOME:-NULL})"
  [[ ! -e ${DSB_DRPB} ]] && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Dashboard Dropbox directory does not exists (${DSB_DRPB:-NULL})"
  [[ ! -e ${SUBLER} ]]   && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Subler CLI is not installed (${SUBLER:-NULL})"
  [[ ! -e ${mp4art} ]]   && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m Mp4art is not installed (${mp4art:-NULL})"
  [[ ! -e ${convert} ]]  && err_msg="${err_msg}\n  \033[1;91m"$'\302\267'"\033[0m ImageMagick is not installed (${convert:-NULL})"

  [[ -n ${err_msg} ]] && error "${err_msg}" -ec 1
}

progress_bar () {
  n=$1
  total=$2

  ch=$((n * BAR_LENGTH / total))
  sp=$((BAR_LENGTH - ch))
  percentage=$(bc <<< "scale=2; ${n} * 100 / ${total}")

  printf "\r[%.${ch}s%.${sp}s] %.2f%% (%d / %d)\r" "${BAR_CHR}" "${BAR_SPC}" "${percentage}" "${n}" "${total}"
}

# Headers for each format
headers () {
  # debug "Writing format headers"
  (( $JSON )) && json.header
  (( $CSV ))  && csv.header
  (( $HTML )) && html.header
  (( $DB ))   && db.header
}

# Footers for each format
footers () {
  # debug "Writing format footers"
  (( $JSON )) && json.footer
  (( $CSV ))  && csv.footer
  (( $HTML )) && html.footer
  (( $DB ))   && db.footer
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

  artworks=$(echo ${artworks} | sed "s#${DSB_HOME}/##g") # | sed 's/ /%20/g' | sed 's/#/%23/g')
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

  # debug "Writing format entry"

  (( $JSON )) && json.entry "${entries[@]}"
  (( $CSV ))  && csv.entry  "${entries[@]}"
  (( $HTML )) && html.entry "${entries[@]}"
  (( $DB ))   && db.entry   "${entries[@]}"
}

create () {
  headers

  # Delete all the Artworks created before.
  [[ -d ${DSB_ARTW} ]] && rm -rf "${DSB_ARTW}/*"

  # If you are in development mode, do not take all the movies.
  # Uncomment the 3 above lines to test with the movies from DEV_INIT_MOVIE to (DEV_INIT_MOVIE + DEV_TOTAL):
  # DEV_INIT_MOVIE=500
  # DEV_TOTAL=10
  # ls "${SOURCE}"/*/* | tail -${DEV_INIT_MOVIE}| head -${DEV_TOTAL} > ${TMP_MOVIES_LIST_FILE}

  # Uncomment the above line for production
  ls "${SOURCE}"/*/* > ${TMP_MOVIES_LIST_FILE}

  TOTAL_MOVIES=$(cat ${TMP_MOVIES_LIST_FILE} | wc -l | tr -d ' ')
  ID=1
  while read movies
  do
    ok_format=0
    ok_backup=0

    movie=${movies##*/}

    [[ ${movie##*.} == "m4v" ]] && ok_format=1
    (( ${CHK_BKP} )) && \
      [[ -n $(ls "${BKPSRC}"/*/* | grep "${movie}") ]] && \
      ok_backup=1

    name=
    artist=
    cast=
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
      [[ ${data} =~ "Cast:" ]]             && cast=$(echo ${data} | sed 's/Cast: //')
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

    # These values were taken from iTunes
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

    (( $PROGRESS_BAR )) && progress_bar $ID $TOTAL_MOVIES
    debug "Getting data from movie #${ID} / ${TOTAL_MOVIES}: '${name}'"

    # Artist my be repeated as they are taken from Artist and Cast.
    # Remove the repeated artists
    tmp_artist=$(echo "${artist}, ${cast}" | tr ',' '\n' | sed 's/^ *//' | sed 's/ *$//' | sort | uniq | tr '\n' ',' | sed 's/,/, /g')
    artist=${tmp_artist%, }

    # Remove repeated genres, just in case
    tmp_genres=$(echo "${genres}" | tr ',' '\n' | sed 's/^ *//' | sed 's/ *$//' | sort | uniq | tr '\n' ',' | sed 's/,/, /g')
    genres=${tmp_genres%, }

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
  done < <(cat ${TMP_MOVIES_LIST_FILE})

  # If there is a progress bar, print a new line
  (( $PROGRESS_BAR )) && echo

  footers

  # Copy the JSON, CSV and DB files to Dropbox
  cp "${JSON_DB}" "${DSB_DRPB}"
  cp "${CSV_MOVIES}" "${DSB_DRPB}"
  cp "${DB_MOVIES}" "${DSB_DRPB}"
}

notify () {
  if (( ${FIREBASE} ))
  then
    message="Movies Dashboard have been created in your Site, exported to Dropbox and published in Firebase"
  else
    message="Movies Dashboard have been created in your Site and exported to Dropbox"
  fi
  ok "${message}"
  [[ -e /usr/bin/osascript ]] && \
    /usr/bin/osascript -e "Display notification \"${message}\" with title \"${TITLE}\""
}

turn_on_all_formats () {
  debug "Will create all the formats and publish data to Firebase"
  JSON=1;
  CSV=1;
  HTML=1;
  DB=1;
  FIREBASE=1;
}

publish () {
  [[ ! -e ${JSON_DB} ]] && error "JSON Database not found" -ec 1

  debug "Publishing database to Firebase (${FIREBASE_URL})"
  cat "${JSON_DB}" | curl -X PUT -d @- "${FIREBASE_URL}/.json?print=silent"
}

validate

JSON=0;
CSV=0;
HTML=0;
DB=0;
FIREBASE=0;
QUITE=0;

while (( $# ))
do
  case $1 in
    # -h and --help are covered in common.sh script
    --all|-a)
      turn_on_all_formats
    ;;

    --quite|-q)
      QUITE=1
    ;;

    --json)
      JSON=1
      debug "Will create JSON format"
    ;;
    --csv)
      CSV=1
      debug "Will create CSV format"
    ;;
    --html)
      HTML=1
      debug "Will create HTML format"
    ;;
    --db)
      DB=1
      debug "Will create SQLite format"
    ;;

    --chk-bkp)
      CHK_BKP=1
      debug "Will check the movies backup"
    ;;

    --publish)
      JSON=1
      FIREBASE=1
      debug "Will create JSON format and publish data in Firebase"
    ;;

    --debug)
      QUITE=0
    ;;

    *)
      warn "What is this: ($1)?"
    ;;
  esac
  shift
done

PROGRESS_BAR=0 && [[ $DEBUG -eq 0 && $QUITE -eq 0 ]] && PROGRESS_BAR=1

# Check if the file for that format exists and load it
(( $JSON )) && [[ -e ${SCRIPT_DIR}/format/json.sh ]] && source ${SCRIPT_DIR}/format/json.sh
(( $CSV  )) && [[ -e ${SCRIPT_DIR}/format/csv.sh  ]] && source ${SCRIPT_DIR}/format/csv.sh
(( $HTML )) && [[ -e ${SCRIPT_DIR}/format/html.sh ]] && source ${SCRIPT_DIR}/format/html.sh
(( $DB   )) && [[ -e ${SCRIPT_DIR}/format/db.sh   ]] && source ${SCRIPT_DIR}/format/db.sh

create

(( $FIREBASE )) && [[ -e ${JSON_DB} ]] && publish

notify
