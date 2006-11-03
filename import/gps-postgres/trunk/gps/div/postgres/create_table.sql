-- $Id$

CREATE TABLE logg (
    date timestamptz,
    lat numeric,
    lon numeric,
    alt numeric,
    sted text,
    description text,
    koor point,
    avst numeric
);
