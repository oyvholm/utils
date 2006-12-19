-- $Id$

-- OBS! Må fjernes når jeg er ferdig med å teste og opprenskinga er gjort.
\echo
\echo ================ Slett skrotpunkter. ================

DELETE FROM logg WHERE lat < 51;
DELETE FROM logg WHERE lat > 71;
DELETE FROM logg WHERE lon < -2;
DELETE FROM logg WHERE lon > 26;
DELETE FROM logg WHERE date < '2002-01-01';
DELETE FROM logg WHERE date > '2010-01-01';
DELETE FROM logg WHERE date BETWEEN '2005-09-24' AND '2006-02-08';
DELETE FROM logg WHERE date BETWEEN '2003-02-15 17:58:26Z' AND '2003-02-15 17:59:37Z';
DELETE FROM logg WHERE date BETWEEN '2003-07-15 16:06:58Z' AND '2003-07-15 16:08:05Z';
DELETE FROM logg WHERE ele = -1500;

\echo
\echo ================ Oppdater koor ================

UPDATE logg SET koor = point(lat,lon) WHERE koor IS NULL;

-- \echo
-- \echo ================ Oppdater sted ================
--
-- UPDATE logg set sted = clname(koor) WHERE sted IS NULL;
--
-- \echo
-- \echo ================ Oppdater dist ================
--
-- UPDATE logg set dist = cldist(koor) WHERE dist IS NULL;

\echo
\echo ================ Sett avstanden hjemmefra ================

UPDATE logg SET avst = '(60.42543,5.29959)'::point <-> koor WHERE avst IS NULL;

\echo
\echo ================ Slett høyder som er på trynet ================

UPDATE logg SET ele = NULL WHERE ele < -1500;
UPDATE logg SET ele = NULL WHERE ele > 29000;

\echo
\echo ================ Rund av veipunkter til fem desimaler ================

UPDATE wayp SET koor = point(round(koor[0]::numeric, 5), round(koor[1]::numeric, 5));

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
                koor[0], koor[1],
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
            DISTINCT ON (date,lat,lon,descr) *
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
