-- $Id$

-- Returnerer navnet på det nærmeste veipunktet i wayp.
DROP FUNCTION clname(point);
CREATE OR REPLACE FUNCTION clname(point) RETURNS text
AS $$
SELECT name FROM (
        SELECT
            name,
            ($1 <-> coor)
            AS avs
            FROM wayp
            WHERE ($1 <-> coor) < 0.05
            ORDER BY avs
            LIMIT 1
    ) AS s;
$$ LANGUAGE SQL;

-- Returnerer avstanden (i grader) til det nærmeste veipunktet i wayp.
DROP FUNCTION cldist(point);
CREATE OR REPLACE FUNCTION cldist(point) RETURNS numeric
AS $$
SELECT round(avs::numeric, 5) FROM (
        SELECT
            ($1 <-> coor)
            AS avs
            FROM wayp
            WHERE ($1 <-> coor) < 0.05
            ORDER BY avs
            LIMIT 1
    ) AS s;
$$ LANGUAGE SQL;

-- Returnerer antall sekunder sia midnatt for en dato.
DROP FUNCTION secmidnight(timestamptz);
CREATE OR REPLACE FUNCTION secmidnight(timestamptz) RETURNS double precision
AS $$
SELECT extract(hour from $1) * 3600 + extract(minute from $1) * 60 + extract(second from $1);
$$ LANGUAGE SQL;
