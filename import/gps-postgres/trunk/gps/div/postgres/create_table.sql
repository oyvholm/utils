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
    wp_koor point,
    wp_name text,
    wp_ele numeric,
    wp_type text,
    wp_time timestamptz,
    wp_cmt text, -- GPS waypoint comment. Sent to the GPS as comment.
    wp_desc text, -- A text description. Additional info intended for the user, not the GPS.
    wp_src text,
    wp_sym text
);

CREATE TABLE events (
    date timestamptz,
    koor point,
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
