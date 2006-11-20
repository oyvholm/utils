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

CREATE TABLE wayp (
    lat numeric(8, 5),
    lon numeric(8, 5),
    ele numeric,
    name text,
    cmt text, -- GPS waypoint comment. Sent to GPS as comment.
    descr text, -- A text description. Additional info intended for the user, not the GPS.
    type text,
    koor point
);

CREATE TABLE events (
    begindate timestamptz, -- Ganske eksakt tidspunt ved start
    enddate timestamptz, -- Ganske eksakt tidspunkt ved slutt
    cabegin interval,
    caend interval,
    lat numeric,
    lon numeric,
    descr text,
    koor point,
    flags text[],
    persons text[],
    data bytea
);
