CREATE EXTENSION postgis_tiger_geocoder CASCADE;
CREATE EXTENSION address_standardizer CASCADE;
GRANT USAGE ON SCHEMA tiger TO PUBLIC;
GRANT USAGE ON SCHEMA tiger_data TO PUBLIC;
GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA tiger TO PUBLIC;
GRANT SELECT, REFERENCES, TRIGGER ON ALL TABLES IN SCHEMA tiger_data TO PUBLIC;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA tiger TO PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA tiger_data GRANT SELECT, REFERENCES ON TABLES TO PUBLIC;
SELECT na.address, na.streetname, na.streettypeabbrev, na.zip
  FROM normalize_address('1 Devonshire Place, Boston, MA 02109') AS na;
UPDATE tiger.loader_lookuptables SET load = true WHERE table_name = 'zcta510';
UPDATE tiger.loader_lookuptables SET load = true WHERE load = false AND lookup_name IN('tract', 'bg', 'tabblock');
