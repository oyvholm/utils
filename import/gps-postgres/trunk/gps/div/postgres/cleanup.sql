-- $Id$

BEGIN;
    SELECT count(*)
        AS "Antall i wayp før rensking"
        FROM wayp;
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
    SELECT count(*)
        AS "Antall i wayp etter rensking"
        FROM wayp;
COMMIT;
