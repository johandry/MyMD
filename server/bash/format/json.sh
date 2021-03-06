JSON_MOVIES="${DSB_HOME}/movies.json";
JSON_GENRES="${DSB_HOME}/genres.json";
JSON_ARTISTS="${DSB_HOME}/artists.json";
JSON_DB="${DSB_HOME}/mymd.json";

json.header() {
	echo "  {" > "${JSON_MOVIES}"
	echo "  {" > "${JSON_GENRES}"
	echo "  {" > "${JSON_ARTISTS}"
}

json.footer() {
	echo -e "    }\n  }" >> "${JSON_MOVIES}"
	echo -e "    }\n  }" >> "${JSON_GENRES}"
	echo -e "    }\n  }" >> "${JSON_ARTISTS}"

  # Create a JSON file with the 3 JSON files
  echo -e "{\n  \"movies\": {" > "${JSON_DB}"
  tail -n +2 "${JSON_MOVIES}" | sed '$d' >> "${JSON_DB}"
  echo -e "  },\n  \"artists\": {" >> "${JSON_DB}"
  tail -n +2 "${JSON_ARTISTS}" | sed '$d' >> "${JSON_DB}"
  echo -e "  },\n  \"genres\": {" >> "${JSON_DB}"
  tail -n +2 "${JSON_GENRES}" | sed '$d' >> "${JSON_DB}"
  echo -e "  }\n}\n" >> "${JSON_DB}"
}

artist.entry() {
  local name=${1}
  # id=$(echo $name | tr '.$#[]/' '_')
	id=$(grep '"name"' "${JSON_ARTISTS}" | wc -l | sed 's/ //g')
	(( id++ ))
  [[ $(tail -n -1 "${JSON_ARTISTS}" | head -1 | sed 's/ //g') != "{" ]] && echo "    }," >> "${JSON_ARTISTS}"
  cat << EOAENTRY >> "${JSON_ARTISTS}"
    "${id}": {
			"id": ${id},
      "name": "${name}"
EOAENTRY
	return ${id}
}

genre.entry() {
  local name=${1}
  # id=$(echo $name | tr '.$#[]/' '_')
	id=$(grep '"name"' "${JSON_GENRES}" | wc -l | sed 's/ //g')
	(( id++ ))
  [[ $(tail -n -2 "${JSON_GENRES}" | head -1 | sed 's/ //g') != "{" ]] && echo "    }," >> "${JSON_GENRES}"
  cat << EOAENTRY >> "${JSON_GENRES}"
    "${id}": {
			"id": ${id},
      "name": "${name}"
EOAENTRY
	return ${id}
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

	g=$(echo "${main_genre}" | sed -e 's/^ *//' -e 's/ *$//')
  if ! grep -q "\"name\": \"${g}\"" "${JSON_GENRES}"
  	then
    genre.entry "${g}"
		genre_id=$?
	else
		genre_id=$(cat "${JSON_GENRES}" | tr -d '\n' | sed "s/.*\"id\": \(.*\),.*\"name\": \"${g}\".*/\1/")
  fi
	main_genre_id="${genre_id}"
  # movie_genres_list="\"${g}\""
	# movie_genres_list_id="${genre_id}"

	IFS=,
	movie_genres_list=''
	movie_genres_list_id=''
  genres_list=( $genres )
  for g in "${genres_list[@]}"
  do
    g=$(echo "${g}" | sed -e 's/^ *//' -e 's/ *$//')
    movie_genres_list="${movie_genres_list}, \"${g}\""
    if ! grep -q "\"name\": \"${g}\"" "${JSON_GENRES}"
    	then
    	genre.entry "${g}"
			genre_id=$?
		else
			genre_id=$(cat "${JSON_GENRES}" | tr -d '\n' | sed "s/.*\"id\": \(.*\),.*\"name\": \"${g}\".*/\1/")
	  fi
		movie_genres_list_id="${movie_genres_list_id}, ${genre_id}"
  done
  movie_genres_list="[ ${movie_genres_list#, } ]"
	movie_genres_list_id="[ ${movie_genres_list_id#, } ]"

  movie_artist_list=''
	movie_artist_list_id=''
  artists_list=( $artist )
  for p in "${artists_list[@]}"
  do
    p=$(echo "${p}" | sed -e 's/^ *//' -e 's/ *$//')
    movie_artist_list="${movie_artist_list}, \"${p}\""
    if ! grep -q "\"name\": \"${p}\"" "${JSON_ARTISTS}"
    	then
    	artist.entry "${p}"
			artist_id=$?
		else
			artist_id=$(cat "${JSON_ARTISTS}" | tr -d '\n' | sed "s/.*\"id\": \(.*\),.*\"name\": \"${p}\".*/\1/")
	  fi
		movie_artist_list_id="${movie_artist_list_id}, ${artist_id}"
  done
  unset IFS
  movie_artist_list="[ ${movie_artist_list#, } ]"
	movie_artist_list_id="[ ${movie_artist_list_id#, } ]"

  [[ ${ID} -ne 1 ]] && echo "    }," >> "${JSON_MOVIES}"
  cat << EOJSONENTRY >> "${JSON_MOVIES}"
    "${ID}": {
      "id": ${ID},
      "name":"${name}",
      "filename":"${filename}",
      "artwork":"${artwork}",
      "artworks":"${artworks}",
      "hd":${hd},
      "m4v":${ok_format},
      "backup":${ok_backup},
      "artist":${movie_artist_list},
			"artistID":${movie_artist_list_id},
      "mainGenre":"${main_genre}",
			"mainGenreID":"${main_genre_id}",
      "genres":${movie_genres_list},
			"genresID":${movie_genres_list_id},
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
}
