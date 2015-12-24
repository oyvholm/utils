PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE synced (
  file TEXT
    CONSTRAINT synced_file_length
      CHECK (length(file) > 0)
    UNIQUE
    NOT NULL,
  orig TEXT,
  rev TEXT
    CONSTRAINT synced_rev_length
      CHECK (length(rev) = 40 OR rev = ''),
  date TEXT
    CONSTRAINT synced_date_length
      CHECK (date IS NULL OR length(date) = 19)
    CONSTRAINT synced_date_valid
      CHECK (date IS NULL OR datetime(date) IS NOT NULL)
);
INSERT INTO "synced" VALUES('bin/create-html','Lib/std/bash','7365eb760dd4bd581aeedc53fcc10cb1b8ba17ca','2015-12-13 09:20:30');
INSERT INTO "synced" VALUES('bin/stats','Lib/std/perl','edf69ab8cacd6e39d48f3e5b842e89e64edd86a1','2015-12-12 07:06:46');
INSERT INTO "synced" VALUES('index.md','Lib/std/markdown','edf69ab8cacd6e39d48f3e5b842e89e64edd86a1','2015-12-12 05:02:39');
CREATE TABLE todo (
  file TEXT
    CONSTRAINT todo_file_length
      CHECK(length(file) > 0)
    UNIQUE
    NOT NULL
  ,
  pri INTEGER
    CONSTRAINT todo_pri_range
      CHECK(pri BETWEEN 1 AND 5)
  ,
  comment TEXT
);
COMMIT;
