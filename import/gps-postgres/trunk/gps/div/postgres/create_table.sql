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
    lat numeric,
    lon numeric,
    ele numeric,
    name text,
    cmt text, -- GPS waypoint comment. Sent to GPS as comment.
    descr text, -- A text description. Additional info intended for the user, not the GPS.
    type text,
    koor point
);
