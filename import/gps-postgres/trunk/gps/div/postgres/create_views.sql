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

/*** Fjernest ***/

CREATE OR REPLACE VIEW fjernest
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('week', date)
        ) *
        FROM logg
    ) as s
    ORDER BY avst DESC;

CREATE OR REPLACE VIEW fjernest_siste_aar
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('week', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 year ago') as s
    ORDER BY avst DESC;

CREATE OR REPLACE VIEW fjernest_siste_halvaar
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('week', date)
        ) *
        FROM logg
        WHERE date > now()+interval '0.5 year ago'
    ) as s
    ORDER BY avst DESC;

CREATE OR REPLACE VIEW fjernest_siste_maaned
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('hour', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 month ago'
    ) as s
    ORDER BY avst DESC;

CREATE OR REPLACE VIEW fjernest_siste_uke
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('hour', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 week ago'
    ) as s
    ORDER BY avst DESC;

CREATE OR REPLACE VIEW fjernest_siste_dogn
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('minute', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 day ago'
    ) as s
    ORDER BY avst DESC;

/*** Intervaller ***/

CREATE OR REPLACE VIEW minutt
    AS SELECT * from (
        SELECT DISTINCT ON (
            sted, date_trunc('minute', date)
        ) *
        FROM logg
    ) as s
    ORDER BY date DESC;
