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
INSERT INTO "synced" VALUES('.gitattributes','Lib/std/book-cmark/.gitattributes','ffe510ea2fbb5baf8f7f5573d86e3168a9ce7df0','2015-12-24 17:11:25');
INSERT INTO "synced" VALUES('.gitignore','Lib/std/book-cmark/.gitignore','ffe510ea2fbb5baf8f7f5573d86e3168a9ce7df0','2015-12-24 17:11:25');
INSERT INTO "synced" VALUES('Makefile','Lib/std/book-cmark/Makefile','ffe510ea2fbb5baf8f7f5573d86e3168a9ce7df0','2015-12-24 17:11:25');
INSERT INTO "synced" VALUES('bin/create-html','Lib/std/book-cmark/bin/create-html','ffe510ea2fbb5baf8f7f5573d86e3168a9ce7df0','2015-12-24 17:11:25');
INSERT INTO "synced" VALUES('bin/stats','Lib/std/book-cmark/bin/stats','ffe510ea2fbb5baf8f7f5573d86e3168a9ce7df0','2015-12-24 17:11:25');
INSERT INTO "synced" VALUES('dat/STDprojnameDTS.sql','Lib/std/book-cmark/dat/STDprojnameDTS.sql','ffe510ea2fbb5baf8f7f5573d86e3168a9ce7df0','2015-12-24 17:11:25');
INSERT INTO "synced" VALUES('index.md','Lib/std/book-cmark/index.md','ffe510ea2fbb5baf8f7f5573d86e3168a9ce7df0','2015-12-24 17:11:25');
INSERT INTO "synced" VALUES('synced.sql','',NULL,NULL);
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
