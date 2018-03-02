# Oregon Mileposts

## How to make the CSV file
1. Getting the "ogr" tools. They live in a package called `gdal`, which stands for Geographic Data Abstraction Library. If you installed PostGIS, you have it, because PostGIS depends on it for a number of operations. You probably also have it if you're using any Python or R geospatial tools. By the way, `gdal` is pronounced "goo-dal".
2. Go to <http://spatialdata.oregonexplorer.info/geoportal/details;id=35defd130a394981acee60dbeb2e469a>.
3. Download the file and unzip it. You'll get a directory `Mileposts_2014`.
4. Type

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
5. Enter `ogr2ogr -f CSV Mileposts_2014.csv Mileposts_2014.gdb`. `ogr2ogr` will do the conversion.
