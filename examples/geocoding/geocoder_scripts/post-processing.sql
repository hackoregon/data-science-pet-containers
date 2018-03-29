SELECT install_missing_indexes();
VACUUM ANALYZE VERBOSE tiger.addr;
VACUUM ANALYZE VERBOSE tiger.edges;
VACUUM ANALYZE VERBOSE tiger.faces;
VACUUM ANALYZE VERBOSE tiger.featnames;
VACUUM ANALYZE VERBOSE tiger.place;
VACUUM ANALYZE VERBOSE tiger.cousub;
VACUUM ANALYZE VERBOSE tiger.county;
VACUUM ANALYZE VERBOSE tiger.state;
VACUUM ANALYZE VERBOSE tiger.zip_lookup_base;
VACUUM ANALYZE VERBOSE tiger.zip_state;
VACUUM ANALYZE VERBOSE tiger.zip_state_loc;
SELECT
  g.rating As r,
  ST_X(geomout) As lon,
  ST_Y(geomout) As lat,
  pprint_addy(addy) As paddress
FROM
  geocode(
    '329 NE Couch St, Portland, OR 97232'
  ) As g;
SELECT
  pprint_addy(addy),
  st_astext(geomout),
  rating
FROM
  geocode_intersection(
    'Grand Ave', 'Couch St', 'OR', 'Portland'
  );
