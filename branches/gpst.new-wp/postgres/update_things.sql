-- $Id$

\echo
\echo ================ Rund av veipunkter til seks desimaler ================

UPDATE wayp SET coor = point(
    round(coor[0]::numeric, 6),
    round(coor[1]::numeric, 6)
);

\echo
\echo ================ Fjern duplikater i wayp ================

SELECT count(*)
    AS "Antall i wayp før rensking"
    FROM wayp;

BEGIN ISOLATION LEVEL SERIALIZABLE;
    CREATE TEMPORARY TABLE dupfri
    ON COMMIT DROP
    AS (
        SELECT
            DISTINCT ON (
                coor[0], coor[1],
                name,
                ele,
                type,
                time,
                cmt,
                descr,
                src,
                sym
            ) *
            FROM wayp
    );
    TRUNCATE wayp;
    INSERT INTO wayp (
        SELECT *
            FROM dupfri
            ORDER BY name
    );
COMMIT;

SELECT count(*)
    AS "Antall i wayp etter rensking"
    FROM wayp;

\echo
\echo ================ Fjern duplikater i events ================

SELECT count(*)
    AS "Antall i events før rensking"
    FROM events;

BEGIN ISOLATION LEVEL SERIALIZABLE;
    CREATE TEMPORARY TABLE dupfri
    ON COMMIT DROP
    AS (
        SELECT
            DISTINCT ON (date, coor[0], coor[1], descr) *
            FROM events
    );
    TRUNCATE events;
    INSERT INTO events (
        SELECT *
            FROM dupfri
            ORDER BY date
    );
COMMIT;

SELECT count(*)
    AS "Antall i events etter rensking"
    FROM events;

\echo
\echo ================ Oppdater koordinater for bilder ================

UPDATE pictures SET coor = findpos(date)
    WHERE coor IS NULL;

\echo ================ Rund av bildekoordinater ================
UPDATE pictures SET coor = point(
    round(coor[0]::numeric, 6),
    round(coor[1]::numeric, 6)
);

\echo
\echo ================ Fjern duplikater i pictures ================

SELECT count(*)
    AS "Antall i pictures før rensking"
    FROM pictures;

BEGIN ISOLATION LEVEL SERIALIZABLE;
    CREATE TEMPORARY TABLE dupfri
    ON COMMIT DROP
    AS (
        SELECT
            DISTINCT ON (date, coor[0], coor[1], descr, filename, author) *
            FROM pictures
    );
    TRUNCATE pictures;
    INSERT INTO pictures (
        SELECT *
            FROM dupfri
            ORDER BY date
    );
COMMIT;

SELECT count(*)
    AS "Antall i pictures etter rensking"
    FROM pictures;

\i distupdate.sql
