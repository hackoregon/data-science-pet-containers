Origin-Destination Data
================

## Source

This dataset comes from the US census Bureau’s Longitudinal
Employer-Household Dynamics (LEHD) website -
<https://lehd.ces.census.gov/>. The data we are using is the LEHD
Origin-Destination Employment Statistics (LODES) subset -
<https://lehd.ces.census.gov/data/#lodes>.

## Structure of the tables

This dataset is a schema `origin_destination` with two tables:

  - `or_xwalk` - the Oregon “crosswalk” table. This table lists the
    census blocks that are within Oregon, and in a few cases, partially
    in neighboring states. This table gives basic facts about the census
    block, such as which state legislative districts it is in. The
    primary key is `tabblk2010`, the FIPS code for the census block.

  - `origin_destination` - the main data table. Although the source data
    includes all of Oregon, this table contains only the rows within the
    “Portland-Vancouver-Hillsboro, OR-WA” Core Based Statistical Area
    (CBSA) that are in Oregon.
    
    The columns are:
    
      - year integer: the data year. Years 2002 through 2015 are
        included.
      - w\_geocode text: the census block FIPS code for the jobs
      - h\_geocode text: the census block FIPS code for the workerss
        homes
      - s000 integer: Total number of jobs
      - sa01 integer: Number of jobs of workers age 29 or younger
      - sa02 integer: Number of jobs for workers age 30 to 54
      - sa03 integer: Number of jobs for workers age 55 or older
      - se01 integer: Number of jobs with earnings $1250/month or less
      - se02 integer: Number of jobs with earnings $1251/month to
        $3333/month
      - se03 integer: Number of jobs with earnings greater than
        $3333/month
      - si01 integer: Number of jobs in Goods Producing industry sectors
      - si02 integer: Number of jobs in Trade, Transportation, and
        Utilities industry sectors
      - si03 integer: Number of jobs in All Other Services industry
        sectors

## Geometry data for the census blocks

The geometry and other data for the census block FIPS codes in
`or_xwalk` and `origin_destination` can be found in another schema /
table, `tl_2017_41_tabblock10.tl_2017_41_tabblock10`. In that table,
column `geoid10` is the census block FIPS code corresponding to
`tabblk2010` in `or_xwalk` or `w_geocode` and `h_geocode` in
`origin_destination`. Column `wkb_geometry` in that table gives the
geometry (well-known binary (WKB), multipolygon, SRID = 4269).
