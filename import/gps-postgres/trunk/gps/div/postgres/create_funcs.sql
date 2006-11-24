-- $Id$

CREATE OR REPLACE FUNCTION closest(numeric, numeric) RETURNS text AS $$
    SELECT name::text
        FROM wayp
        WHERE point($1, $2) = (
            SELECT koor
                FROM wayp
                WHERE point($1, $2) <-> koor = min(point($1, $2) <-> koor)
        );
$$ LANGUAGE SQL;
