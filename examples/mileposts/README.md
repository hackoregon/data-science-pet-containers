# Oregon Mileposts

## Git LFS
This example stores binary data using Git LFS. You'll need to install it to use it with Git. Instructions can be found at <https://git-lfs.github.com/>.

## Getting the "ogr" tools
They live in a package called `gdal`, which stands for Geographic Data Abstraction Library. If you installed PostGIS, you probably have it, because some PostGIS operations depend on it. You probably also have it if you're using any Python or R geospatial tools. And, of course, it's installed in the `postgis` Docker image in this repository. By the way, `gdal` is pronounced "goo-dal". If you don't have `gdal` you can get it from <https://trac.osgeo.org/gdal/wiki/DownloadingGdalBinaries>.

## How to make the CSV file
1. Go to <http://spatialdata.oregonexplorer.info/geoportal/details;id=35defd130a394981acee60dbeb2e469a>.
2. Download the file and unzip it. You'll get a directory `Mileposts_2014`.
3. Type

    ```
    cd Mileposts_2014
    ogrinfo Mileposts_2014.gdb
    ```

    The response will be

    ```
    Had to open data source read-only.
    INFO: Open of `Mileposts_2014.gdb/'
          using driver `OpenFileGDB' successful.
    1: mileposts_2014 (Measured Point)

    ```

    Good news! You have a GDB (geographic database) that `ogr2ogr` can convert to CSV!
4. Enter `ogr2ogr -f CSV Mileposts_2014.csv Mileposts_2014.gdb`. `ogr2ogr` will do the conversion.
