-- $Id$
-- File ID: 4765dc0a-fafb-11dd-874c-000475e441b9

-- Rund av veipunkter til seks desimaler -- {{{
\echo
\echo ================ Rund av veipunkter til seks desimaler ================

UPDATE wayp SET coor = point(
    round(coor[0]::numeric, 6),
    round(coor[1]::numeric, 6)
);
-- }}}
-- Fjern duplikater i wayp -- {{{
\echo
\echo ================ Fjern duplikater i wayp ================

COPY (SELECT '======== Antall i wayp før rensking: ' || count(*) from wayp) to STDOUT;

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

COPY (SELECT '======== Antall i wayp etter rensking: ' || count(*) from wayp) to STDOUT;
-- }}}

-- Fjern duplikater i events -- {{{
\echo
\echo ================ Fjern duplikater i events ================

COPY (SELECT '======== Antall i events før rensking: ' || count(*) from events) to STDOUT;

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

COPY (SELECT '======== Antall i events etter rensking: ' || count(*) from events) to STDOUT;
-- }}}

-- Oppdater koordinater for bilder -- {{{
\echo
\echo ================ Oppdater koordinater for bilder ================

UPDATE pictures SET coor = findpos(date)
    WHERE coor IS NULL;
-- }}}
-- Rund av bildekoordinater -- {{{
\echo ================ Rund av bildekoordinater ================
UPDATE pictures SET coor = point(
    round(coor[0]::numeric, 6),
    round(coor[1]::numeric, 6)
);
-- }}}
-- Fjern duplikater i pictures -- {{{
\echo
\echo ================ Fjern duplikater i pictures ================

COPY (SELECT '======== Antall i pictures før rensking: ' || count(*) from pictures) to STDOUT;

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

COPY (SELECT '======== Antall i pictures etter rensking: ' || count(*) from pictures) to STDOUT;
-- }}}

-- Oppdater koordinater for filmer -- {{{
\echo
\echo ================ Oppdater koordinater for filmer ================

UPDATE film SET coor = findpos(date)
    WHERE coor IS NULL;
-- }}}
-- Rund av filmkoordinater -- {{{
\echo ================ Rund av filmkoordinater ================
UPDATE film SET coor = point(
    round(coor[0]::numeric, 6),
    round(coor[1]::numeric, 6)
);
-- }}}
-- Fjern duplikater i film -- {{{
\echo
\echo ================ Fjern duplikater i film ================

COPY (SELECT '======== Antall i film før rensking: ' || count(*) from film) to STDOUT;

BEGIN ISOLATION LEVEL SERIALIZABLE;
    CREATE TEMPORARY TABLE dupfri
    ON COMMIT DROP
    AS (
        SELECT
            DISTINCT ON (date, coor[0], coor[1], descr, filename, author) *
            FROM film
    );
    TRUNCATE film;
    INSERT INTO film (
        SELECT *
            FROM dupfri
            ORDER BY date
    );
COMMIT;

COPY (SELECT '======== Antall i film etter rensking: ' || count(*) from film) to STDOUT;
-- }}}

-- Oppdater koordinater for lyd -- {{{
\echo
\echo ================ Oppdater koordinater for lyd ================

UPDATE lyd SET coor = findpos(date)
    WHERE coor IS NULL;
-- }}}
-- Rund av lydkoordinater -- {{{
\echo ================ Rund av lydkoordinater ================
UPDATE lyd SET coor = point(
    round(coor[0]::numeric, 6),
    round(coor[1]::numeric, 6)
);
-- }}}
-- Fjern duplikater i lyd -- {{{
\echo
\echo ================ Fjern duplikater i lyd ================

COPY (SELECT '======== Antall i lyd før rensking: ' || count(*) from lyd) to STDOUT;

BEGIN ISOLATION LEVEL SERIALIZABLE;
    CREATE TEMPORARY TABLE dupfri
    ON COMMIT DROP
    AS (
        SELECT
            DISTINCT ON (date, coor[0], coor[1], descr, filename, author) *
            FROM lyd
    );
    TRUNCATE lyd;
    INSERT INTO lyd (
        SELECT *
            FROM dupfri
            ORDER BY date
    );
COMMIT;

COPY (SELECT '======== Antall i lyd etter rensking: ' || count(*) from lyd) to STDOUT;
-- }}}

\i distupdate.sql
