#!/bin/bash

# ============= Directories ============= 
# Directory where iTunes store the movies
SOURCE="/Volumes/Media Center/Shared iTunes/iTunes Media/Movies"
# Directory of backups of the iTunes movies
BKPSRC="/Volumes/Backup01/Shared iTunes/iTunes Media/Movies"

# Directory to create the dashboard
DSB_HOME="/Users/johandry/Sites/MyMD/app/movies"
# Directory to create the dashboard in DropBox
DSB_DRPB="/Users/johandry/Dropbox/Shared/Movies"
# Directory to create the movies artwork
DSB_ARTW="${DSB_HOME}/../img/artwork"
# ========== End of Directories ==========

# Download sublerCLI from:
SUBLER="/usr/local/bin/subler"
# Download mp4art from: http://mp4v2.googlecode.com/svn/doc/1.9.0/ToolGuide.html#TOC6
mp4art="/usr/local/bin/mp4art"
# Install ImageMagick with: brew install ImageMagick
convert="/usr/local/bin/convert"

[[ ! -e ${SOURCE} ]] && err_msg="\n\tSource directory does not exists (${SOURCE})"
[[ ! -e ${BKPSRC} ]] && err_msg="\n\tBackup directory does not exists (${BKPSRC})"
[[ ! -e ${DSB_HOME} ]] && err_msg="\n\tDashboard Home directory does not exists (${DSB_HOME})"
[[ ! -e ${DSB_DRPB} ]] && err_msg="\n\tDashboard Dropbox directory does not exists (${DSB_DRPB})"
[[ -n ${err_msg} ]] && echo -e "ERROR: ${err_msg}" && exit 1

# Files to save the Movies Dashboard
JSON_MOVIES="${DSB_HOME}/movies.json";
CSV_MOVIES="${DSB_HOME}/movies.csv";
HTML_MOVIES="${DSB_HOME}/index.html";
DB_MOVIES="${DSB_HOME}/movies.db";

headers () {
  # JSON
  echo "[" > "${JSON_MOVIES}"

  # CSV
  echo "Name,Filename,Artwork,HD,M4V,Backup,Artist,Main Genre,Genres,Release Date,Description,Rating,Studio,Director,Producers,Screenwriters,Media Kind,Path" > "${CSV_MOVIES}"

  # HTML
  cat << EOHTMLHEADER > "${HTML_MOVIES}"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Movies Dashboard</title>
    <!-- Description, Keywords and Author -->
    <meta name="description" content="Movies Dashboard with information about all my movies from their metadata.">
    <meta name="keywords" content="Movies, Metadata">
    <meta name="author" content="Johandry Amador">
    
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Fonts -->
    <link href='http://fonts.googleapis.com/css?family=Open+Sans:400,300,700' rel='stylesheet' type='text/css'>
    <link href='http://fonts.googleapis.com/css?family=Inder' rel='stylesheet' type='text/css'>
    <link href='http://fonts.googleapis.com/css?family=Pacifico' rel='stylesheet' type='text/css'>
    <link href='http://fonts.googleapis.com/css?family=Open+Sans+Condensed:300,700' rel='stylesheet' type='text/css'>
    
    <!-- Styles -->
    <!-- Bootstrap CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <!-- Font awesome CSS -->
    <link href="css/font-awesome.min.css" rel="stylesheet"> 
    <!-- Custom CSS -->
    <link href="css/style.css" rel="stylesheet">
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="img/favicon.ico">
  </head>
  <body>
    <table>
      <caption>Movies Dashboard</caption>
      <thead>
        <tr>
          <th>Name</th>
          <th>Artwork</th>
          <th>Filename</th>
          <th>HD</th>
          <th>M4V</th>
          <th>Backup</th>
          <th>Artist</th>
          <th>Main Genre</th>
          <th>Genres</th>
          <th>Release Date</th>
          <th>Description</th>
          <th>Rating</th>
          <th>Studio</th>
          <th>Director</th>
          <th>Producers</th>
          <th>Screenwriters</th>
          <th>Media Kind</th>
          <th>Path</th>
        </tr>
      </thead>
      <tbody>
EOHTMLHEADER

  #SQLite
  rm -f "${DB_MOVIES}"
  cat << EOSQLHEADER | sqlite3 "${DB_MOVIES}"
CREATE TABLE Movies (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  name                  TEXT   NOT NULL,
  artwork               TEXT,
  filename              TEXT   NOT NULL,
  hd                    INTEGER,
  format                INTEGER,
  backup                INTEGER,
  main_genre_id         INTEGER NOT NULL,
  release_date          DATE,
  description           TEXT,
  rating_id             INTEGER NOT NULL,
  media_kind_id         INTEGER NOT NULL,
  path                  TEXT,

  FOREIGN KEY (main_genre_id) REFERENCES Genres(id),
  FOREIGN KEY (rating_id)     REFERENCES Ratings(id),
  FOREIGN KEY (media_kind_id) REFERENCES MediaKinds(id)
);

CREATE TABLE Genres (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  name                  TEXT   NOT NULL
);

CREATE TABLE People (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  name                  TEXT   NOT NULL
);

CREATE TABLE Ratings (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  name                  TEXT   NOT NULL
);

CREATE TABLE Studios (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  name                  TEXT   NOT NULL
);

CREATE TABLE MediaKinds (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  name                  TEXT   NOT NULL
);

CREATE TABLE GenresMovies (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  genre_id              INTEGER   NOT NULL,
  movie_id              INTEGER   NOT NULL,

  FOREIGN KEY (genre_id)     REFERENCES Genres(id),
  FOREIGN KEY (movie_id)     REFERENCES Movies(id)
);

CREATE TABLE StudiosMovies (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  studio_id             INTEGER   NOT NULL,
  movie_id              INTEGER   NOT NULL,

  FOREIGN KEY (studio_id)    REFERENCES Studios(id),
  FOREIGN KEY (movie_id)     REFERENCES Movies(id)
);

CREATE TABLE PeopleMovies (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  person_id             INTEGER   NOT NULL,
  movie_id              INTEGER   NOT NULL,
  role_id               INTEGER   NOT NULL,

  FOREIGN KEY (person_id)    REFERENCES People(id),
  FOREIGN KEY (movie_id)     REFERENCES Movies(id),
  FOREIGN KEY (role_id)      REFERENCES Roles(id)
);

CREATE TABLE Roles (
  id    INTEGER PRIMARY KEY    AUTOINCREMENT,
  name                  TEXT   NOT NULL
);

INSERT INTO Roles ( name ) VALUES ( "Actor" );
INSERT INTO Roles ( name ) VALUES ( "Director" );
INSERT INTO Roles ( name ) VALUES ( "Screenwriter" );
INSERT INTO Roles ( name ) VALUES ( "Producer" );
EOSQLHEADER
}

footers () {
  # JSON
  echo -e "  }\n]" >> "${JSON_MOVIES}"

  # CSV

  # HTML
  cat << EOHTMLFOOTER >> "${HTML_MOVIES}"
      </tbody>
    </table>
    <!-- Javascript files -->
    <!-- jQuery -->
    <script src="js/jquery.js"></script>
    <!-- Bootstrap JS -->
    <script src="js/bootstrap.min.js"></script>
    <!-- Respond JS for IE8 -->
    <script src="js/respond.min.js"></script>
    <!-- HTML5 Support for IE -->
    <script src="js/html5shiv.js"></script>
    <!-- Custom JS -->
    <script src="js/custom.js"></script>
  </body>
</html>
EOHTMLFOOTER

  # SQLite
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

  local artwork=${artworks%%:*}
  artwork=$(echo ${artworks} | sed "s#${DSB_HOME}/\.\./##" | sed 's/ /%20/g')

  local hd=0
  [[ ${filename} =~ .*HD\).* ]] && hd=1

  
  # JSON
  [[ ${ID} -ne 1 ]] && echo "  }," >> "${JSON_MOVIES}"
  cat << EOJSONENTRY >> "${JSON_MOVIES}"
  {
    "id": ${ID},
    "name":"${name}",
    "filename":"${filename}",
    "artwork":"${artwork}",
    "hd":${hd},
    "m4v":${ok_format},
    "backup":${ok_backup},
    "artist":"${artist}",
    "main Genre":"${main_genre}",
    "genres":"${genres}",
    "release Date":"${release_date}",
    "description":"${description}",
    "rating":"${rating}",
    "studio":"${studio}",
    "director":"${director}",
    "producers":"${producers}",
    "screenwriters":"${screenwriters}",
    "media Kind":"${media_kind}",
    "path":"${path}"
EOJSONENTRY

  # CSV
  echo "\"${name}\",\"${filename}\",\"${artwork}\",${hd},${ok_format},${ok_backup},\"${artist}\",\"${main_genre}\",\"${genres}\",\"${release_date}\",\"${description}\",\"${rating}\",\"${studio}\",\"${director}\",\"${producers}\",\"${screenwriters}\",\"${media_kind}\",\"${path}\"" >> "${CSV_MOVIES}"

  # HTML
  cat << EOHTMLENTRY >> "${HTML_MOVIES}"
        <tr>
          <th>${name}</th>
          <th><img src="${artwork}" style="width:150px;"/></th>
          <td>${hd}</td>
          <td>${ok_format}</td>
          <td>${ok_backup}</td>
          <td>${filename}</td>
          <td>${artist}</td>
          <td>${main_genre}</td>
          <td>${genres}</td>
          <td>${release_date}</td>
          <td>${description}</td>
          <td>${rating}</td>
          <td>${studio}</td>
          <td>${director}</td>
          <td>${producers}</td>
          <td>${screenwriters}</td>
          <td>${media_kind}</td>
          <td>${path}</td>
        </tr>
EOHTMLENTRY
  
  # SQLite
  genre_id=$(echo "SELECT id FROM Genres WHERE name=\"${main_genre}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
  if [[ -z ${genre_id} ]]
    then
    echo "INSERT INTO Genres ( name ) VALUES ( \"${main_genre}\" );" | sqlite3 "${DB_MOVIES}"
    genre_id=$(echo "SELECT id FROM Genres WHERE name=\"${main_genre}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
  fi

  rating_id=$(echo "SELECT id FROM Ratings WHERE name=\"${rating}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
  if [[ -z ${rating_id} ]]
    then
    echo "INSERT INTO Ratings ( name ) VALUES ( \"${rating}\" );" | sqlite3 "${DB_MOVIES}"
    rating_id=$(echo "SELECT id FROM Ratings WHERE name=\"${rating}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
  fi

  media_kind_id=$(echo "SELECT id FROM MediaKinds WHERE name=\"${media_kind}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
  if [[ -z ${media_kind_id} ]]
    then
    echo "INSERT INTO MediaKinds ( name ) VALUES ( \"${media_kind}\" );" | sqlite3 "${DB_MOVIES}"
    media_kind_id=$(echo "SELECT id FROM MediaKinds WHERE name=\"${media_kind}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
  fi

  cat << EOSQLENTRY | sqlite3 "${DB_MOVIES}"
INSERT INTO Movies ( name, artwork, filename, hd, format, backup, main_genre_id, release_date, description, rating_id, media_kind_id, path )
VALUES ( "${name}", "${artwork}", "${filename}", ${hd}, ${ok_format}, ${ok_backup}, ${genre_id}, "${release_date}", "${description}", ${rating_id}, ${media_kind_id}, "${path}" );
EOSQLENTRY

  movie_id=$(echo "SELECT id FROM Movies WHERE name=\"${name}\" AND filename=\"${filename}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)

  IFS=,
  # This will let us do this query:
  # SELECT 
  #   M.name AS "Movie",
  #   G.name AS "Genre"
  # FROM 
  #   Movies AS M 
  #   JOIN GenresMovies AS GM ON M.id = GM.movie_id 
  #   JOIN Genres AS G ON G.id = GM.genre_id 
  # WHERE G.name = "Science Fiction";
  genres_list=( $genres )
  for g in "${genres_list[@]}"
  do
    g=$(echo "${g}" | sed -e 's/^ *//' -e 's/ *$//')
    g_id=$(echo "SELECT id FROM Genres WHERE name=\"${g}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    if [[ -z ${g_id} ]]
      then
      echo "INSERT INTO Genres ( name ) VALUES ( \"${g}\" );" | sqlite3 "${DB_MOVIES}"
      g_id=$(echo "SELECT id FROM Genres WHERE name=\"${g}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    fi
    echo "INSERT INTO GenresMovies ( genre_id, movie_id ) VALUES ( ${g_id}, ${movie_id} );" | sqlite3 "${DB_MOVIES}"
  done

  # This will let us do this query:
  # SELECT 
  #   M.name AS "Movie",
  #   P.name AS "Actor",
  #   R.name AS "Role"
  # FROM 
  #   Movies AS M 
  #   JOIN PeopleMovies AS PM ON M.id = PM.movie_id 
  #   JOIN People AS P ON P.id = PM.person_id 
  #   JOIN Roles AS R ON R.id = PM.role_id 
  # WHERE 
  #   P.name = "Roger Moore"
  #   AND R.name = "Actor";
  artists_list=( $artist )
  for p in "${artists_list[@]}"
  do
    p=$(echo "${p}" | sed -e 's/^ *//' -e 's/ *$//')
    p_id=$(echo "SELECT id FROM People WHERE name=\"${p}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    if [[ -z ${p_id} ]]
      then
      echo "INSERT INTO People ( name ) VALUES ( \"${p}\" );" | sqlite3 "${DB_MOVIES}"
      p_id=$(echo "SELECT id FROM People WHERE name=\"${p}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    fi
    role_id=$(echo "SELECT id FROM Roles WHERE name=\"Actor\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    echo "INSERT INTO PeopleMovies ( person_id, movie_id, role_id ) VALUES ( ${p_id}, ${movie_id}, ${role_id} );" | sqlite3 "${DB_MOVIES}"
  done

  # This will let us do this query:
  # SELECT 
  #   M.name AS "Movie",
  #   P.name AS "Director",
  #   R.name AS "Role"
  # FROM 
  #   Movies AS M 
  #   JOIN PeopleMovies AS PM ON M.id = PM.movie_id 
  #   JOIN People AS P ON P.id = PM.person_id 
  #   JOIN Roles AS R ON R.id = PM.role_id 
  # WHERE 
  #   P.name = "Roger Moore"
  #   AND R.name = "Director";
  director_list=( $director )
  for p in "${director_list[@]}"
  do
    p=$(echo "${p}" | sed -e 's/^ *//' -e 's/ *$//')
    p_id=$(echo "SELECT id FROM People WHERE name=\"${p}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    if [[ -z ${p_id} ]]
      then
      echo "INSERT INTO People ( name ) VALUES ( \"${p}\" );" | sqlite3 "${DB_MOVIES}"
      p_id=$(echo "SELECT id FROM People WHERE name=\"${p}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    fi
    role_id=$(echo "SELECT id FROM Roles WHERE name=\"Director\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    echo "INSERT INTO PeopleMovies ( person_id, movie_id, role_id ) VALUES ( ${p_id}, ${movie_id}, ${role_id} );" | sqlite3 "${DB_MOVIES}"
  done  

  # This will let us do this query:
  # SELECT 
  #   M.name AS "Movie",
  #   P.name AS "Screenwriter",
  #   R.name AS "Role"
  # FROM 
  #   Movies AS M 
  #   JOIN PeopleMovies AS PM ON M.id = PM.movie_id 
  #   JOIN People AS P ON P.id = PM.person_id 
  #   JOIN Roles AS R ON R.id = PM.role_id 
  # WHERE 
  #   P.name = "Roger Moore"
  #   AND R.name = "Screenwriter";
  screenwriters_list=( $screenwriters )
  for p in "${screenwriters_list[@]}"
  do
    p=$(echo "${p}" | sed -e 's/^ *//' -e 's/ *$//')
    p_id=$(echo "SELECT id FROM People WHERE name=\"${p}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    if [[ -z ${p_id} ]]
      then
      echo "INSERT INTO People ( name ) VALUES ( \"${p}\" );" | sqlite3 "${DB_MOVIES}"
      p_id=$(echo "SELECT id FROM People WHERE name=\"${p}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    fi
    role_id=$(echo "SELECT id FROM Roles WHERE name=\"Screenwriter\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    echo "INSERT INTO PeopleMovies ( person_id, movie_id, role_id ) VALUES ( ${p_id}, ${movie_id}, ${role_id} );" | sqlite3 "${DB_MOVIES}"
  done  

  # This will let us do this query:
  # SELECT 
  #   M.name AS "Movie",
  #   P.name AS "Producer",
  #   R.name AS "Role"
  # FROM 
  #   Movies AS M 
  #   JOIN PeopleMovies AS PM ON M.id = PM.movie_id 
  #   JOIN People AS P ON P.id = PM.person_id 
  #   JOIN Roles AS R ON R.id = PM.role_id 
  # WHERE 
  #   P.name = "Roger Moore"
  #   AND R.name = "Producer";
  producers_list=( $producers )
  for p in "${producers_list[@]}"
  do
    p=$(echo "${p}" | sed -e 's/^ *//' -e 's/ *$//')
    p_id=$(echo "SELECT id FROM People WHERE name=\"${p}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    if [[ -z ${p_id} ]]
      then
      echo "INSERT INTO People ( name ) VALUES ( \"${p}\" );" | sqlite3 "${DB_MOVIES}"
      p_id=$(echo "SELECT id FROM People WHERE name=\"${p}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    fi
    role_id=$(echo "SELECT id FROM Roles WHERE name=\"Producer\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    echo "INSERT INTO PeopleMovies ( person_id, movie_id, role_id ) VALUES ( ${p_id}, ${movie_id}, ${role_id} );" | sqlite3 "${DB_MOVIES}"
  done  

  # This will let us do this query:
  # SELECT 
  #   M.name AS "Movie",
  #   S.name AS "Studio"
  # FROM 
  #   Movies AS M 
  #   JOIN StudiosMovies AS SM ON M.id = SM.movie_id 
  #   JOIN Studios AS S ON S.id = SM.studio_id 
  # WHERE S.name = "MGM";
  studio_list=( $studio )
  for s in "${studio_list[@]}"
  do
    s=$(echo "${s}" | sed -e 's/^ *//' -e 's/ *$//')
    s_id=$(echo "SELECT id FROM Studios WHERE name=\"${s}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    if [[ -z ${s_id} ]]
      then
      echo "INSERT INTO Studios ( name ) VALUES ( \"${s}\" );" | sqlite3 "${DB_MOVIES}"
      s_id=$(echo "SELECT id FROM Studios WHERE name=\"${s}\";" | sqlite3 "${DB_MOVIES}" 2>/dev/null)
    fi
    echo "INSERT INTO StudiosMovies ( studio_id, movie_id ) VALUES ( ${s_id}, ${movie_id} );" | sqlite3 "${DB_MOVIES}"
  done

  unset IFS

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

  # Get the movie artwork
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
done < <(ls "${SOURCE}"/*/* | head -50) 
# Replace above line for: 'done < <(ls "${SOURCE}"/*/* | head -5)' to test with the first 5 movies.
footers

# Copy the JSON, CSV and DB files to Dropbox
cp "${JSON_MOVIES}" "${DSB_DRPB}" 
cp "${CSV_MOVIES}" "${DSB_DRPB}"
cp "${DB_MOVIES}" "${DSB_DRPB}"

/usr/bin/osascript -e 'Display notification "Movies Dashboard have been created in your Site and exported to Dropbox" with title "Movies Dashboard"'
