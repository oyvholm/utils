-- $Id$

CREATE TABLE logg (
    date timestamptz,
    lat numeric,
    lon numeric,
    ele numeric,
    sted text,
    dist numeric(8, 5),
    description text,
    coor point,
    avst numeric
);

CREATE TABLE wayp (
    coor point,
    name text,
    ele numeric(6, 1),
    type text,
    time timestamptz,
    cmt text, -- GPS waypoint comment. Sent to the GPS as comment.
    descr text, -- A text description. Additional info intended for the user, not the GPS.
    src text,
    sym text
);

CREATE TABLE tmpwayp AS
    SELECT * from wayp LIMIT 0;

CREATE TABLE events (
    date timestamptz,
    coor point,
    descr text,
    begindate timestamptz, -- Ganske eksakt tidspunt ved start
    enddate timestamptz, -- Ganske eksakt tidspunkt ved slutt
    cabegin interval,
    caend interval,
    lat numeric,
    lon numeric,
    flags text[],
    persons text[],
    data bytea
);

CREATE TABLE stat (
    lastupdate timestamptz,
    laststed timestamptz
);
