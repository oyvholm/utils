-- $Id$
-- File ID: 2d79727a-fafb-11dd-9a1e-000475e441b9

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
    \echo ================ Oppdater wayp.numpoints ================
    UPDATE wayp SET numpoints = numpoints(name);
COMMIT;
