-- $Id$

-- Returnerer navnet på det nærmeste veipunktet i wayp.
DROP FUNCTION clname(point);
CREATE OR REPLACE FUNCTION clname(point) RETURNS text
AS $$
SELECT wp_name FROM (
        SELECT
            wp_name,
            ($1 <-> wp_koor)
            AS avs
            FROM wayp
            WHERE ($1 <-> wp_koor) < 0.05
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
            ($1 <-> wp_koor)
            AS avs
            FROM wayp
            WHERE ($1 <-> wp_koor) < 0.05
            ORDER BY avs
            LIMIT 1
    ) AS s;
$$ LANGUAGE SQL;
