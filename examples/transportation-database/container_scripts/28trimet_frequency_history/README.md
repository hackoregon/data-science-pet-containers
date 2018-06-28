# TRIMET FREQUENCY SCRAPING

`download_GTFS_archive.py`

There are two sites that contain the GTFS archives this script downloads from.
* http://www.gtfs-data-exchange.com/agency/trimet/
* http://transitfeeds.com/p/trimet/43

### USAGE:
`python download_GTFS_archive.py <OPTIONS>`

#### OPTIONS:

`-h` shows the help message to tell you your options.

`-l <FILENAME_PATH>` Exports a list of all the individual .zip file URLS to `<FILENAME_PATH>`. Does **NOT** download them. 

`-d <FOLDERNAME_PATH>` Downloads each .zip file archive into `<FOLDERNAME_PATH>`.

The `-l` and `-d` flags can be used together or individually.

Requirements are listed in the `requirements.txt` file, but this script makes use
of `python3 requests` and `beautifulsoup4`.

### NOTES:
The first link contains 34 pages of .zip files, while the second contains 21. All told there's ~1000 archive folders of ~30 MB each.