 -- $Id$

CREATE OR REPLACE VIEW siste_aar
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('week', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 year ago'
    ) as s
    ORDER BY date;

CREATE OR REPLACE VIEW siste_halvaar
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('week', date)
        ) *
        FROM logg
        WHERE date > now()+interval '0.5 year ago'
    ) as s
    ORDER BY date;

CREATE OR REPLACE VIEW siste_maaned
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('hour', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 month ago'
    ) as s
    ORDER BY s.date;

CREATE OR REPLACE VIEW siste_uke
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('hour', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 week ago'
    ) as s
    ORDER BY date;

CREATE OR REPLACE VIEW siste_dogn
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('minute', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 day ago'
    ) as s
    ORDER BY date;

/*** De 50.000 punktene med høyest fjernesthjemmefrahet. ***/

CREATE OR REPLACE VIEW fjernest
    AS SELECT * from logg
        ORDER BY avst DESC limit 50000;

CREATE OR REPLACE VIEW fjernest_siste_aar
    AS SELECT * from logg
        WHERE date > now()+interval '1 year ago'
        ORDER BY avst DESC limit 50000;

CREATE OR REPLACE VIEW fjernest_siste_halvaar
    AS SELECT * from logg
        WHERE date > now()+interval '0.5 year ago'
        ORDER BY avst DESC limit 50000;

CREATE OR REPLACE VIEW fjernest_siste_maaned
    AS SELECT * FROM logg
        WHERE date > now()+interval '1 month ago'
        ORDER BY avst DESC limit 50000;

CREATE OR REPLACE VIEW fjernest_siste_uke
    AS SELECT * FROM logg
        WHERE date > now()+interval '1 week ago'
        ORDER BY avst DESC limit 50000;

CREATE OR REPLACE VIEW fjernest_siste_dogn
    AS SELECT * FROM logg
        WHERE date > now()+interval '1 day ago'
        ORDER BY avst DESC limit 50000;

/*** Intervaller ***/

CREATE OR REPLACE VIEW minutt
    AS SELECT * from (
        SELECT DISTINCT ON (
            date_trunc('minute', date)
        ) *
        FROM logg
    ) as s
    ORDER BY date DESC;

/*** Formater ***/

CREATE OR REPLACE VIEW gpx
    AS select * from logg limit 1;

-- Lister ut events sammen med loggen.
CREATE OR REPLACE VIEW ev AS
    SELECT * FROM (
        SELECT 'l' AS flag, date,           koor, sted, null as descr, avst
        FROM logg
        UNION ALL
        SELECT 'e' AS flag, date, point(lat,lon), null, descr as descr, null
        FROM events
    ) AS u
    ORDER BY date;
