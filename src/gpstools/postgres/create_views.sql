 -- $Id$

-- siste_aar: List ut alle plasser siste år, DISTINCT ON sted og hver uke
CREATE OR REPLACE VIEW siste_aar -- {{{
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('week', date)
        ) *
        FROM logg
        WHERE date > now() + interval '1 year ago'
    ) AS s
    ORDER BY date; -- }}}

-- siste_halvaar: List ut alle plasser siste halvår, DISTINCT ON sted og hver uke
CREATE OR REPLACE VIEW siste_halvaar -- {{{
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('week', date)
        ) *
        FROM logg
        WHERE date > now() + interval '0.5 year ago'
    ) AS s
    ORDER BY date; -- }}}

-- siste_maaned: List ut alle plasser siste måned, DISTINCT ON sted og hver time
CREATE OR REPLACE VIEW siste_maaned -- {{{
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('hour', date)
        ) *
        FROM logg
        WHERE date > now() + interval '1 month ago'
    ) AS s
    ORDER BY date; -- }}}

-- siste_uke: List ut alle plasser siste uka, DISTINCT ON sted og hver time
CREATE OR REPLACE VIEW siste_uke -- {{{
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('hour', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 week ago'
    ) AS s
    ORDER BY date; -- }}}

-- siste_dogn: List ut alle plasser siste døgn, DISTINCT ON sted og hvert minutt
CREATE OR REPLACE VIEW siste_dogn -- {{{
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            sted, date_trunc('minute', date)
        ) *
        FROM logg
        WHERE date > now()+interval '1 day ago'
    ) AS s
    ORDER BY date; -- }}}

/*** Intervaller ***/

CREATE OR REPLACE VIEW minutt -- {{{
    AS SELECT * FROM (
        SELECT DISTINCT ON (
            date_trunc('minute', date)
        ) *
        FROM logg
    ) AS s
    ORDER BY date DESC; -- }}}

/*** Formater ***/

CREATE OR REPLACE VIEW closest AS -- {{{
    SELECT * FROM (
        SELECT DISTINCT ON (sted) * FROM (
            SELECT * FROM LOGG
                ORDER BY dist
        ) AS b
        WHERE sted IS NOT NULL
    ) AS a
        ORDER BY date; -- }}}

CREATE OR REPLACE VIEW gpx AS -- {{{
    SELECT '<trkpt lat="' || coor[0] || '" lon="' || coor[1] || '"> ' ||
        '<ele>' || ele || '</ele> ' ||
        '<time>' || date || '</time> ' ||
    '</trkpt>'
    AS gpx,
    date, coor, ele, sted, dist, description
    FROM logg; -- }}}

CREATE OR REPLACE VIEW gpst AS -- {{{
    SELECT date, coor, ele, sted, dist,
    '<tp> <time>' || date AT TIME ZONE 'UTC' || 'Z' || '</time> <lat>' || coor[0] || '</lat> <lon>' || coor[1] || '</lon> </tp>'
    AS gpst
    FROM logg; -- }}}

-- ev: Lister ut events sammen med loggen.
CREATE OR REPLACE VIEW ev AS -- {{{
    SELECT * FROM (
        SELECT     'gps' AS flag, date, coor, sted || ' (' || dist || ')' AS sted, ele::numeric(8,1), NULL AS descr
            FROM logg
        UNION ALL
        SELECT   'event' AS flag, date, coor, NULL, NULL, descr AS descr
            FROM events
        UNION ALL
        SELECT     'pic' AS flag, date, coor, filename, NULL, NULL
            FROM pictures
    ) AS u
    ORDER BY date; -- }}}

-- wp: Lister ut veipunktene, sortert nord → sør, vest → øst
CREATE OR REPLACE VIEW wp AS -- {{{
    SELECT
        coor AS coor,
        substr(name, 1, 20) AS name,
        type AS type,
        substr(cmt, 1, 20) AS cmt,
        ele AS ele,
        time AS time
        FROM wayp
        ORDER BY coor[0] DESC, coor[1]; -- }}}
