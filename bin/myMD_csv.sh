CSV_MOVIES="${DSB_HOME}/movies.csv";

csv.header() {
	echo "Name,Filename,Artwork,HD,M4V,Backup,Artist,Main Genre,Genres,Release Date,Description,Rating,Studio,Director,Producers,Screenwriters,Media Kind,Path" > "${CSV_MOVIES}"
}

csv.footer() {
	# Nothing to do here
	:
}

csv.entry() {
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

  echo "\"${name}\",\"${filename}\",\"${artwork}\",${hd},${ok_format},${ok_backup},\"${artist}\",\"${main_genre}\",\"${genres}\",\"${release_date}\",\"${description}\",\"${rating}\",\"${studio}\",\"${director}\",\"${producers}\",\"${screenwriters}\",\"${media_kind}\",\"${path}\"" >> "${CSV_MOVIES}"
}