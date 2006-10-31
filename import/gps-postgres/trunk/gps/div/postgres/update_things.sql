-- $Id$

UPDATE logg SET koor = point(lon,lat) WHERE koor IS NULL;
UPDATE logg SET avst = '(5.29959,60.42543)'::point <-> koor WHERE avst IS NULL;

UPDATE logg SET sted = 'Voorbode-anker' WHERE (point(5.34043,60.41756) <-> koor) < 0.0002 AND sted IS NULL;
UPDATE logg SET sted = 'Åstvedt' WHERE (point(5.31534,60.45376) <-> koor) < 0.0002 AND sted IS NULL;
UPDATE logg SET sted = 'Lille Øvre 21' WHERE (point(5.33016,60.39494) <-> koor) < 0.0002 AND sted IS NULL;
UPDATE logg SET sted = 'Blekenberg 47' WHERE (point(5.33325,60.37231) <-> koor) < 0.0002 AND sted IS NULL;
UPDATE logg SET sted = 'Brushytten' WHERE (point(5.35963,60.40060) <-> koor) < 0.0002 AND sted IS NULL;
\echo Leirvik...
UPDATE logg SET sted = 'Leirvik' WHERE (point(5.49540,59.77897) <-> koor) < 0.01 AND sted IS NULL;

\echo England...
UPDATE logg SET sted = 'England' WHERE koor <@ polygon(path('(
    (3.149,58.633),
    (3.163,52.395),
    (-6.437,49.364)
)')) AND sted IS NULL;

\echo London...
UPDATE logg SET sted = 'London' WHERE (point(-0.0824,51.515) <-> koor) < 0.1 AND sted IS NULL;

\echo Leira...
UPDATE logg SET sted = 'Leira' WHERE (point(9.28609,60.95695) <-> koor) < 0.1 AND sted IS NULL;

\echo Hammerfest...
UPDATE logg SET sted = 'Hammerfest' WHERE (point(23.68326,70.65938) <-> koor) < 0.1 AND sted IS NULL;

\echo Kristiansand...
UPDATE logg SET sted = 'Kristiansand' WHERE (point(7.99255,58.14789) <-> koor) < 0.1 AND sted IS NULL;

\echo BA...
UPDATE logg SET sted = 'BA' WHERE (point(5.32275,60.39376) <-> koor) < 0.0002 AND sted IS NULL;

\echo Ragnar...
UPDATE logg SET sted = 'Ragnar' WHERE (point(5.30848,60.38249) <-> koor) < 0.0002 AND sted IS NULL;

\echo København...
UPDATE logg SET sted = 'København' WHERE (point(12.58347,55.702) <-> koor) < 0.5 AND sted IS NULL;
