-- $Id$

DELETE FROM logg WHERE lat < 24;
UPDATE logg SET koor = point(lat,lon) WHERE koor IS NULL;
UPDATE logg SET avst = '(60.42543,5.29959)'::point <-> koor WHERE avst IS NULL;

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
