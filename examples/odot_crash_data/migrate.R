# install the packages we need
if (!dir.exists(Sys.getenv('R_LIBS_USER'))) {
  dir.create(Sys.getenv('R_LIBS_USER'), recursive = TRUE, mode = '0755')
}
install.packages(c("Hmisc", "RPostgres"), 
  quiet = TRUE, lib = Sys.getenv('R_LIBS_USER'), repos = "https://cran.rstudio.com/")

# point to the raw data file
raw_data <- "/home/dbsuper/Raw/Portland_Fatal___Injury_Crashes_2004-2014_Decode.mdb"

# Set environment variables
Sys.setenv(
  PGHOST = "/var/run/postgresql",
  PGPORT = 5432,
  PGUSER = "dbsuper"
)

# define functions
get_mdb_tables <- function(mdb_file) {
  tables <- Hmisc::mdb.get(mdb_file, tables = TRUE)
  return(grep(pattern = "^tbl", x = tables, invert = TRUE, value = TRUE))
}

get_mdb_table <- function(mdb_file, table_name) {
  work <- Hmisc::mdb.get(mdb_file, tables = table_name, allow = "_")
  colnames(work) <- tolower(colnames(work))
  return(work)
}

get_postgresql_connection <- function(dbname) {
  return(DBI::dbConnect(
    drv = RPostgres::Postgres(),
    dbname = dbname
  ))
}

# connect to destination PostgreSQL server and create a database
pgcon <- get_postgresql_connection("postgres")
dummy <- DBI::dbSendStatement(pgcon, "DROP DATABASE IF EXISTS odot_crash_data;")
DBI::dbClearResult(dummy)
dummy <- DBI::dbSendStatement(pgcon, "CREATE DATABASE odot_crash_data;")
DBI::dbClearResult(dummy)
DBI::dbDisconnect(pgcon)

# reconnect to the new database
pgcon <- get_postgresql_connection("odot_crash_data")

# get list of tables from MDB file
tables <- get_mdb_tables(raw_data)
for (table_name in tables) {
  cat("\nMigrating table", table_name, "\n")
  work <- get_mdb_table(raw_data, table_name)
  DBI::dbWriteTable(pgcon, tolower(table_name), work, overwrite = TRUE)
}

# add primary keys
dummy <- DBI::dbSendStatement(
  pgcon,
  "ALTER TABLE public.crash ADD CONSTRAINT crash_pkey PRIMARY KEY (crash_id);"
)
DBI::dbClearResult(dummy)

dummy <- DBI::dbSendStatement(
  pgcon,
  "ALTER TABLE public.partic ADD CONSTRAINT partic_pkey PRIMARY KEY (partic_id);"
)
DBI::dbClearResult(dummy)

dummy <- DBI::dbSendStatement(
  pgcon,
  "ALTER TABLE public.vhcl ADD CONSTRAINT vhcl_pkey PRIMARY KEY (vhcl_id);"
)
DBI::dbClearResult(dummy)

# change ownership!
dummy <- DBI::dbSendStatement(
  pgcon,
  'ALTER DATABASE odot_crash_data OWNER TO "transportation-systems";'
)
DBI::dbClearResult(dummy)

dummy <- DBI::dbSendStatement(
  pgcon,
  'REASSIGN OWNED BY CURRENT_USER TO "transportation-systems";'
)
DBI::dbClearResult(dummy)

# disconnect
DBI::dbDisconnect(pgcon)

# create backups
plain <- paste(
  "pg_dump --format=p --verbose --clean --create --if-exists --dbname=odot_crash_data",
  "gzip -c > /home/dbsuper/Backups/odot_crash_data.sql.gz", sep = " | ")
system(plain)
