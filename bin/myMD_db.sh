DB_MOVIES="${DSB_HOME}/movies.db";

db.header() {
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

db.footer() {
	# Nothing to do here
	:
}

db.entry() {
	declare -a params=("${@}")

	local ID=${params[0]}
  local name=${params[1]}
  local filename=${params[2]}
  local artwork=${params[3]}
  local artworks=${params[4]}
  local hd=${params[5]}
  local ok_format=${params[6]}
  local ok_backup=${params[7]}
  local artist=${params[8]}
  local main_genre=${params[9]}
  local genres=${params[10]}
  local release_date=${params[11]}
  local description=${params[12]}
  local rating=${params[13]}
  local studio=${params[14]}
  local director=${params[15]}
  local producers=${params[16]}
  local screenwriters=${params[17]}
  local media_kind=${params[18]}
  local path=${params[19]}

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