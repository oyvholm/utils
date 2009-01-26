-- $Id$

-- clname(): Returnerer navnet på det nærmeste veipunktet i wayp.
CREATE OR REPLACE FUNCTION clname(point) RETURNS text -- {{{
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
-- }}}

-- cldist(): Returnerer avstanden (i grader) til det nærmeste veipunktet i wayp.
CREATE OR REPLACE FUNCTION cldist(point) RETURNS numeric -- {{{
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
$$ LANGUAGE SQL; -- }}}

-- findpos(): Beregn koordinater for et tidspunkt som ligger mellom to trackpunkter.
CREATE OR REPLACE FUNCTION findpos(currtime timestamptz) RETURNS point AS $$ -- {{{
DECLARE
    firstdate timestamptz;
    lastdate timestamptz;
    firsttime timestamptz;
    firstcoor point;
    lasttime timestamptz;
    lastcoor point;
    currlat numeric;
    currlon numeric;
BEGIN
    -- RAISE NOTICE '-----------------------------------';
    SELECT INTO firstdate date
        FROM logg
        ORDER BY date
        LIMIT 1;
    SELECT INTO lastdate date
        FROM logg
        ORDER BY date DESC
        LIMIT 1;
    IF currtime < firstdate OR currtime > lastdate THEN
        return(NULL);
    END IF;

    SELECT INTO firsttime date
        FROM logg
        WHERE date <= currtime
        ORDER BY date DESC
        LIMIT 1;
    SELECT INTO firstcoor coor
        FROM logg
        WHERE date <= currtime
        ORDER BY date DESC
        LIMIT 1;
    SELECT INTO lasttime date
        FROM logg
        WHERE date >= currtime
        ORDER BY date
        LIMIT 1;
    SELECT INTO lastcoor coor
        FROM logg
        WHERE date >= currtime
        ORDER BY date
        LIMIT 1;
    -- RAISE NOTICE 'currtime = %', currtime;
    -- RAISE NOTICE 'firsttime = %, firstcoor = %', firsttime, firstcoor;
    -- RAISE NOTICE 'lasttime = %, lastcoor = %', lasttime, lastcoor;

    IF firsttime = lasttime THEN
        RETURN(firstcoor);
    END IF;

    currlat = firstcoor[0] + 
    (
        (
            lastcoor[0]-firstcoor[0]
        ) *
        (
            (
                EXTRACT(EPOCH FROM currtime)-EXTRACT(EPOCH FROM firsttime)
            )
            /
            (
                EXTRACT(EPOCH FROM lasttime)-EXTRACT(EPOCH FROM firsttime)
            )
        )
    );
    currlon = firstcoor[1] + 
    (
        (
            lastcoor[1]-firstcoor[1]
        ) *
        (
            (
                EXTRACT(EPOCH FROM currtime)-EXTRACT(EPOCH FROM firsttime)
            )
            /
            (
                EXTRACT(EPOCH FROM lasttime)-EXTRACT(EPOCH FROM firsttime)
            )
        )
    );
    -- RAISE NOTICE 'currcoor = (%,%)', currlat, currlon;
    RETURN (currlat,currlon);
END;
$$ LANGUAGE plpgsql; -- }}}

-- wherepos(): Returnerer en streng med dato, posisjon, nærmeste navn og avstand til nærmeste punkt.
CREATE OR REPLACE FUNCTION wherepos(currtime timestamptz) RETURNS text AS $$ -- {{{
DECLARE
    currpos point;
    currsted text;
    currdist numeric;
    currlat numeric(9, 6);
    currlon numeric(9, 6);
BEGIN
    currpos = findpos(currtime);
    currlat = currpos[0];
    currlon = currpos[1];
    currsted = clname(currpos);
    currdist = cldist(currpos);
    RETURN(currtime || ' - ' || currlat::text || ' ' || currlon::text || ' - ' || currsted || ' - ' || currdist);
END;
$$ LANGUAGE plpgsql; -- }}}

-- loop_wayp_new(): Loop gjennom alle entryene i wayp_new og legg dem inn i systemet.
CREATE OR REPLACE FUNCTION loop_wayp_new() RETURNS void AS $$ -- {{{
DECLARE
    curr_id integer;
    currpoint point;
BEGIN
    -- FOR curr IN SELECT * FROM wayp_new LOOP
    --     NULL;
    -- END LOOP;
    LOOP
        curr_id = first_wayp_new();
        IF curr_id IS NOT NULL THEN
            RAISE NOTICE 'curr_id er ikke null: %', curr_id;
            currpoint = (SELECT coor FROM wayp_new WHERE id = curr_id);
            IF (SELECT coor FROM wayp WHERE coor[0] = currpoint[0] AND coor[1] = currpoint[1]) IS NOT NULL THEN
                RAISE NOTICE '% finnes allerede i wayp', currpoint;
                INSERT INTO wayp_rej SELECT * FROM wayp_new WHERE id = curr_id;
            ELSE
                RAISE NOTICE '% er ikke i wayp', currpoint;
                INSERT INTO wayp SELECT * FROM wayp_new WHERE id = curr_id;
                PERFORM update_trackpoint(currpoint);
            END IF;
            DELETE FROM wayp_new WHERE id = curr_id;
            -- COPY (SELECT name FROM wayp WHERE coor::varchar = currpoint::varchar)
            --     TO STDOUT;
        ELSE
            RAISE NOTICE 'currpoint er null';
            EXIT;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql; -- }}}

-- update_trackpoint(): Oppdater alle feltene i en viss omkrets av punktet som spesifiseres.
CREATE OR REPLACE FUNCTION update_trackpoint(currpoint point) RETURNS void AS $$ -- {{{
BEGIN
    RAISE NOTICE 'starter update_trackpoint(%), %', currpoint, clname(currpoint);
    -- Sted og dist
    UPDATE logg SET sted = clname(coor), dist = cldist(coor)
        WHERE ($1 <-> coor) < 0.05;
    RAISE NOTICE 'update_trackpoint(%) er ferdig', currpoint;
END;
$$ LANGUAGE plpgsql;
-- }}}

-- first_wayp_new(): Returnerer id for den eldste i wayp_new.
CREATE OR REPLACE FUNCTION first_wayp_new() RETURNS integer AS $$ -- {{{
BEGIN
    RETURN (SELECT id FROM wayp_new ORDER BY id LIMIT 1);
END
$$ LANGUAGE plpgsql;
-- }}}

-- secmidnight(): Returnerer antall sekunder sia midnatt for en dato.
CREATE OR REPLACE FUNCTION secmidnight(timestamptz) RETURNS double precision -- {{{
AS $$
SELECT extract(hour from $1) * 3600 + extract(minute from $1) * 60 + extract(second from $1);
$$ LANGUAGE SQL; -- }}}
