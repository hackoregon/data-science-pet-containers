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
