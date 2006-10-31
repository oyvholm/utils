-- $Id$

CREATE TABLE logg (
    date timestamptz,
    lon numeric,
    lat numeric,
    alt numeric
);

CREATE INDEX date_idx on logg(date);
CREATE INDEX lon_idx on logg(lon);
CREATE INDEX lat_idx on logg(lat);
CREATE INDEX alt_idx on logg(alt);
