-- $Id$

-- OBS! Må fjernes når jeg er ferdig med å teste og opprenskinga er gjort.
\echo
\echo ================ Slett skrotpunkter. ================

DELETE FROM logg WHERE coor[0] < 51;
DELETE FROM logg WHERE coor[0] > 71;
DELETE FROM logg WHERE coor[1] < -2;
DELETE FROM logg WHERE coor[1] > 26;
DELETE FROM logg WHERE date < '2002-01-01';
DELETE FROM logg WHERE date > '2010-01-01';
DELETE FROM logg WHERE date BETWEEN '2005-09-24' AND '2006-02-08';
DELETE FROM logg WHERE date BETWEEN '2003-02-15 17:58:26Z' AND '2003-02-15 17:59:37Z';
DELETE FROM logg WHERE date BETWEEN '2003-07-15 16:06:58Z' AND '2003-07-15 16:08:05Z';
DELETE FROM logg WHERE date = '2002-12-10 01:25:28Z';
DELETE FROM logg WHERE date = '2002-10-06 22:41:10Z';
DELETE FROM logg WHERE date = '2006-02-12 03:33:15Z';
DELETE FROM logg WHERE date = '2006-02-19 14:15:07Z';
DELETE FROM logg WHERE ele = -1500;

\echo
\echo ================ Slett høyder som er på trynet ================

UPDATE logg SET ele = NULL WHERE ele < -1500;
UPDATE logg SET ele = NULL WHERE ele > 29000;

\echo
\echo ================ Rund av veipunkter til fem desimaler ================

UPDATE wayp SET coor = point(
    round(coor[0]::numeric, 5),
    round(coor[1]::numeric, 5)
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

\i distupdate.sql
