-- $Id$

BEGIN ISOLATION LEVEL SERIALIZABLE;
    \echo
    \echo ================ Oppdater name og dist ================

    UPDATE logg SET name = clname(coor), dist = cldist(coor)
        WHERE date > (
            SELECT lastname FROM stat
                WHERE lastupdate IS NOT NULL
                ORDER BY lastupdate DESC LIMIT 1
        )
        OR date IS NULL;

    INSERT INTO stat (lastupdate, lastname) VALUES (
        now(),
        (SELECT max(date) FROM logg)
    );
COMMIT;
