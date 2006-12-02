-- $Id$

DROP FUNCTION closest(point);
CREATE OR REPLACE FUNCTION closest(point) RETURNS text
AS $$
SELECT wp_name || ' (' || round(avs::numeric, 5) || ')' FROM (
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

DROP FUNCTION plass(point);
CREATE OR REPLACE FUNCTION plass(point) RETURNS text
AS $$
SELECT wp_name FROM (
        SELECT
            wp_name,
            ($1 <-> wp_koor)
            AS avs
            FROM wayp
            WHERE ($1 <-> wp_koor) < 0.0002
            ORDER BY avs
            LIMIT 1
    ) AS s;
$$ LANGUAGE SQL;
