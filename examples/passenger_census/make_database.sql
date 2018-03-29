\connect postgres

-- create a fresh database
DROP DATABASE IF EXISTS "transportation-systems-passenger-census";
CREATE DATABASE "transportation-systems-passenger-census" WITH OWNER = "transportation-systems";
\connect "transportation-systems-passenger-census"

CREATE TABLE passenger_census (
  summary_begin_date date,
  route_number integer,
  direction integer,
  service_key text,
  stop_seq integer,
  location_id integer,
  public_location_description text,
  ons integer,
  offs integer,
  x_coord double precision,
  y_coord double precision
);
ALTER TABLE passenger_census OWNER TO "transportation-systems";

\copy passenger_census from '/home/dbsuper/Raw/passenger_census.csv' with csv header

-- we don't have PostGIS so we just add a column with the SRID so consumers know what they have!
-- see ../../docs/ridership_data_dictionary.md
ALTER TABLE passenger_census ADD COLUMN epsg_srid integer;
UPDATE passenger_census
  SET epsg_srid = 2913;

-- create a primary key - Django needs it
ALTER TABLE passenger_census
  ADD COLUMN id serial;
ALTER TABLE passenger_census
  ADD CONSTRAINT passenger_census_pkey PRIMARY KEY (id);
