-- $Id$

SELECT count(*)
    AS "Antall i wayp før rensking"
    FROM wayp;

BEGIN ISOLATION LEVEL SERIALIZABLE;
    CREATE TEMPORARY TABLE dupfri
    ON COMMIT DROP
    AS (
        SELECT
            DISTINCT ON (lat,lon,name) *
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
