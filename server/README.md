# Server Side Application
These are the applications to generate the database of movies from the iTunes Media directory.
The database(s) will be created in the ../db/ directory to be used in different ways by the different clients.

## Bash
Execute the createDashboard.sh script using parameters for the format to get the database. The formats are: json, cvs, html and sqlite. You can also use --all parameter to generate them all. Use the -h or --help to get all the different options.

Example:
```
# Create all the formats
./createDashboard.sh    

# Same as previous example
./createDashboard.sh  --all

# Creates only the JSON file
./createDashboard.sh --json

# Creates the JSON file and the SQLite DB file
./createDashboard.sh --json --db  
```
