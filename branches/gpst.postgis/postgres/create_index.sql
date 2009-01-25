-- $Id$

CREATE INDEX log_date_idx on logg(date);
CREATE INDEX log_coor0_idx on logg((coor[0]));
CREATE INDEX log_coor1_idx on logg((coor[1]));
CREATE INDEX log_ele_idx on logg(ele);
CREATE INDEX log_sted_idx on logg(sted);
CREATE INDEX log_dist_idx on logg(dist);
CREATE INDEX log_avst_idx on logg(avst);

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

CREATE INDEX ev_date_idx ON events (date);
CREATE INDEX ev_begindate_idx ON events (begindate);
CREATE INDEX ev_enddate_idx ON events (enddate);
CREATE INDEX ev_cabegin_idx ON events (cabegin);
CREATE INDEX ev_caend_idx ON events (caend);
CREATE INDEX ev_coor0_idx ON events ((coor[0]));
CREATE INDEX ev_coor1_idx ON events ((coor[1]));
CREATE INDEX ev_descr_idx ON events (descr);
CREATE INDEX ev_flags_idx ON events (flags);
CREATE INDEX ev_persons_idx ON events (persons);
CREATE INDEX ev_data_idx ON events (data);
