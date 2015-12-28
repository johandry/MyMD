JSON_MOVIES="${DSB_HOME}/movies.json";
JSON_GENRES="${DSB_HOME}/genres.json";
JSON_ARTISTS="${DSB_HOME}/artists.json";

json.header() {
	echo "[" > "${JSON_MOVIES}"
	echo "[" > "${JSON_GENRES}"
	echo "[" > "${JSON_ARTISTS}"
}

json.footer() {
	echo -e "  }\n]" >> "${JSON_MOVIES}"
	echo -e "  { \"name\": \"\" }\n]" >> "${JSON_GENRES}"
	echo -e "  { \"name\": \"\" }\n]" >> "${JSON_ARTISTS}"
}

json.entry() {
  # debug "Writing JSON entry to ${JSON_MOVIES}"
	local ID=${1}
  local name=${2}
  local filename=${3}
  local artwork=${4}
  local artworks=${5}
  local hd=${6}
  local ok_format=${7}
  local ok_backup=${8}
  local artist=${9}
  local main_genre=${10}
  local genres=${11}
  local release_date=${12}
  local description=${13}
  local rating=${14}
  local studio=${15}
  local director=${16}
  local producers=${17}
  local screenwriters=${18}
  local media_kind=${19}
  local path=${20}

  [[ ${ID} -ne 1 ]] && echo "  }," >> "${JSON_MOVIES}"
  cat << EOJSONENTRY >> "${JSON_MOVIES}"
  {
    "id": ${ID},
    "name":"${name}",
    "filename":"${filename}",
    "artwork":"${artwork}",
    "artworks":"${artworks}",
    "hd":${hd},
    "m4v":${ok_format},
    "backup":${ok_backup},
    "artist":"${artist}",
    "mainGenre":"${main_genre}",
    "genres":"${genres}",
    "releaseDate":"${release_date}",
    "description":"${description}",
    "rating":"${rating}",
    "studio":"${studio}",
    "director":"${director}",
    "producers":"${producers}",
    "screenwriters":"${screenwriters}",
    "mediaKind":"${media_kind}",
    "path":"${path}"
EOJSONENTRY

	g=$(echo "${main_genre}" | sed -e 's/^ *//' -e 's/ *$//')
  if ! grep -q "\"${g}\"" "${JSON_GENRES}"
  	then
  	echo "  { \"name\": \"${g}\" }," >> "${JSON_GENRES}"
  fi

	IFS=,
  genres_list=( $genres )
  for g in "${genres_list[@]}"
  do
    g=$(echo "${g}" | sed -e 's/^ *//' -e 's/ *$//')
    if ! grep -q "\"${g}\"" "${JSON_GENRES}"
    	then
    	echo "  { \"name\": \"${g}\" }," >> "${JSON_GENRES}"
    fi
  done

  artists_list=( $artist )
  for p in "${artists_list[@]}"
  do
    p=$(echo "${p}" | sed -e 's/^ *//' -e 's/ *$//')
    if ! grep -q "\"${p}\"" "${JSON_ARTISTS}"
    	then
    	echo "  { \"name\": \"${p}\" }," >> "${JSON_ARTISTS}"
    fi
  done
  unset IFS
}