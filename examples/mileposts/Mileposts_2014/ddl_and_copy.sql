DROP TABLE IF EXISTS mileposts_2014;
CREATE TABLE mileposts_2014 (
  hwyname text,
  hwynumb text,
  st_hwy_sfx text,
  rdwy_id text,
  mlge_typ text,
  ovlp_cd text,
  mp text,
  mp_desc text,
  mp_disp text,
  lrs_key text,
  lrm_key text,
  lat double precision,
  longtd double precision,
  hrz_col_m text,
  crd_rf_dtm text,
  effectv_dt text,
  gis_prc_dt text
);
\copy mileposts_2014 from 'Mileposts_2014.csv' with csv header
