-- $Id$

-- OBS! Må fjernes når jeg er ferdig med å teste og opprenskinga er gjort.
\echo Slett skrotpunkter.
DELETE FROM logg WHERE lat < 51;
DELETE FROM logg WHERE lat > 71;
DELETE FROM logg WHERE lon < -2;
DELETE FROM logg WHERE lon > 26;
DELETE FROM logg WHERE date < '2002-1-1';
DELETE FROM logg WHERE date > '2007-1-1';
DELETE FROM logg WHERE date BETWEEN '2005-9-24' AND '2006-2-8';
DELETE FROM logg WHERE date BETWEEN '2003-02-15 17:58:26Z' AND '2003-02-15 17:59:37Z';
DELETE FROM logg WHERE date BETWEEN '2003-07-15 16:06:58Z' AND '2003-07-15 16:08:05Z';
DELETE FROM logg WHERE alt = -1500;
\echo
\echo Oppdater koor
UPDATE logg SET koor = point(lat,lon) WHERE koor IS NULL;
\echo
\echo UPDATE logg SET avst = '(60.42543,5.29959)'::point <-> koor WHERE avst IS NULL;
UPDATE logg SET avst = '(60.42543,5.29959)'::point <-> koor WHERE avst IS NULL;
\echo
\echo Slett høyder som er på trynet.
UPDATE logg SET alt = NULL WHERE alt < -1500;
UPDATE logg SET alt = NULL WHERE alt > 29000;
\echo
\echo Rund av veipunkter til fem desimaler
UPDATE wayp SET wp_koor = point(round(wp_koor[0]::numeric, 5), round(wp_koor[1]::numeric, 5));

-- begin-base64 644 -
-- H4sIAMtVSUUCA6XUTW6bQBQH8L1PMTuDhEfz/aGmVW0FKVWsqEridtPNuEwx
-- MhksoJZygN6hR+neF+tgU6XCmMQyKzR6zA/+7zGLz9fTxxjkRZqCh/gRVLVN
-- wHsw/lIU5bJI7MS4tS3H4OtNfB+DYFNkrg4EggxLLiIOKUOMhuBq8gGs/SP+
-- DiCIECJgend92O3TA7hbzOfvRosT1u5XVW9tUvconMq9gjllFyrzLM8t2P3e
-- lhYQfGxRzTRrLIqwuNCa5XZt3dKWKWCyh5KE4j1FCb+UKn9Wq+e6tq4nPoQE
-- ahyuxVub9M1+XxVgbrNym60hhKfzPJR0VK6hlEpLrzLNGTpScY/ZorFLc+OS
-- IbQt+Yc2+4Krj2BT5M9p4YKNqVfBOBgBfwVcQUFpRCFmOozaNeL7zJs1H0i7
-- xjSkgkUTARmV4Sgch+Hpd5wXLincYC77im4sGHLMo4kPQJGjSR7IpEnZvNYG
-- c9x6zYX/Tg2JEkif4d2Ypydb/rBVPYS+VHVkiaDgmqqIUCgUJeIM+rbMqjoz
-- rnplBv6v68asfLP9+EUSak04P0OfTYfM2bTvwGgPJ0LkW//iFrs3qTPlEHio
-- 6EH9+OgGRYqp89Db3Z+ldSuzHRzfl6puthxKRCJMIFeUya7Ne+C/i61jHF0G
-- AAA=
-- ====
