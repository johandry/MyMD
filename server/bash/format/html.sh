HTML_MOVIES="${DSB_HOME}/index.html";

html.header() {
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
}

html.footer() {
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
}

html.entry() {
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

  cat << EOHTMLENTRY >> "${HTML_MOVIES}"
        <tr>
          <th>${name}</th>
          <th><img src="../${artwork}" style="width:150px;"/></th>
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
}