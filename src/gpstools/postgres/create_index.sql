-- $Id$

CREATE INDEX log_date_idx ON logg(date);
CREATE INDEX log_coor0_idx ON logg((coor[0]));
CREATE INDEX log_coor1_idx ON logg((coor[1]));
CREATE INDEX log_ele_idx ON logg(ele);
CREATE INDEX log_sted_idx ON logg(sted);
CREATE INDEX log_dist_idx ON logg(dist);
CREATE INDEX log_id_idx ON logg(id);

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
