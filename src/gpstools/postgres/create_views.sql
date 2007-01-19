 -- $Id$

CREATE OR REPLACE VIEW siste_aar
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('week', date)
        ) *
        FROM logg
        WHERE date > now() + interval '1 year ago'
    ) AS s
    ORDER BY date;

CREATE OR REPLACE VIEW siste_halvaar
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('week', date)
        ) *
        FROM logg
        WHERE date > now() + interval '0.5 year ago'
    ) AS s
    ORDER BY date;

CREATE OR REPLACE VIEW siste_maaned
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('hour', date)
        ) *
        FROM logg
        WHERE date > now() + interval '1 month ago'
    ) AS s
    ORDER BY date;

CREATE OR REPLACE VIEW siste_uke
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('hour', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 week ago'
    ) AS s
    ORDER BY date;

CREATE OR REPLACE VIEW siste_dogn
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('minute', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 day ago'
    ) AS s
    ORDER BY date;

/*** De 50.000 punktene med høyest fjernesthjemmefrahet. ***/

CREATE OR REPLACE VIEW fjernest
    AS SELECT * FROM logg
        ORDER BY avst DESC LIMIT 50000;

CREATE OR REPLACE VIEW fjernest_siste_aar
    AS SELECT * FROM logg
        WHERE date > now()+interval '1 year ago'
        ORDER BY avst DESC LIMIT 50000;

CREATE OR REPLACE VIEW fjernest_siste_halvaar
    AS SELECT * FROM logg
        WHERE date > now()+interval '0.5 year ago'
        ORDER BY avst DESC LIMIT 50000;

CREATE OR REPLACE VIEW fjernest_siste_maaned
    AS SELECT * FROM logg
        WHERE date > now() + interval '1 month ago'
        ORDER BY avst DESC LIMIT 50000;

CREATE OR REPLACE VIEW fjernest_siste_uke
    AS SELECT * FROM logg
        WHERE date > now() + interval '1 week ago'
        ORDER BY avst DESC LIMIT 50000;

CREATE OR REPLACE VIEW fjernest_siste_dogn
    AS SELECT * FROM logg
        WHERE date > now() + interval '1 day ago'
        ORDER BY avst DESC LIMIT 50000;

/*** Intervaller ***/

CREATE OR REPLACE VIEW minutt
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            date_trunc('minute', date)
        ) *
        FROM logg
    ) AS s
    ORDER BY date DESC;

/*** Formater ***/

CREATE OR REPLACE VIEW gpx
    AS SELECT * FROM logg LIMIT 1;

-- Lister ut events sammen med loggen.
CREATE OR REPLACE VIEW ev AS
    SELECT * FROM (
        SELECT     'gps' AS flag, date,           coor, sted || ' (' || dist || ')' AS sted, NULL AS descr, avst
            FROM logg
        UNION ALL
        SELECT   'event' AS flag, date, point(lat,lon), NULL, descr AS descr, NULL
            FROM events
    ) AS u
    ORDER BY date;

CREATE OR REPLACE VIEW wp AS
    SELECT
        coor AS coor,
        substr(name, 1, 20) AS name,
        type AS type,
        substr(cmt, 1, 20) AS cmt,
        ele AS ele,
        time AS time
        FROM wayp
        ORDER BY coor[0] desc, coor[1];
