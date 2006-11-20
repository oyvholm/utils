-- $Id$

CREATE INDEX date_idx on logg(date);
CREATE INDEX lat_idx on logg(lat);
CREATE INDEX lon_idx on logg(lon);
CREATE INDEX alt_idx on logg(alt);
CREATE INDEX sted_idx on logg(sted);
CREATE INDEX avst_idx on logg(avst);

-- DROP INDEX begin_idx;
-- DROP INDEX end_idx;
-- DROP INDEX cabegin_idx;
-- DROP INDEX caend_idx;
-- DROP INDEX lat_idx;
-- DROP INDEX lon_idx;
-- DROP INDEX descr_idx;
-- DROP INDEX flags_idx;
-- DROP INDEX persons_idx;
-- DROP INDEX data_idx;

CREATE INDEX begindate_idx ON events (begindate);
CREATE INDEX enddate_idx ON events (enddate);
CREATE INDEX cabegin_idx ON events (cabegin);
CREATE INDEX caend_idx ON events (caend);
CREATE INDEX lat_idx ON events (lat);
CREATE INDEX lon_idx ON events (lon);
CREATE INDEX descr_idx ON events (descr);
CREATE INDEX flags_idx ON events (flags);
CREATE INDEX persons_idx ON events (persons);
CREATE INDEX data_idx ON events (data);
