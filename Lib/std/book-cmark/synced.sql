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
INSERT INTO "synced" VALUES('.gitattributes','Lib/std/book-cmark/.gitattributes','b51b9ee08973c1bd7cc2afc83bd9c8f7e38e95ec','2015-12-29 00:18:49');
INSERT INTO "synced" VALUES('.gitignore','Lib/std/book-cmark/.gitignore','b51b9ee08973c1bd7cc2afc83bd9c8f7e38e95ec','2015-12-29 00:18:49');
INSERT INTO "synced" VALUES('Makefile','Lib/std/book-cmark/Makefile','80c68f9626ed96fa5610694aa9ba9876b86b9f85','2015-12-30 15:42:34');
INSERT INTO "synced" VALUES('bin/create-html','Lib/std/book-cmark/bin/create-html','7aa9da2bff17f69def4908f0cceef45ccb52819d','2016-01-02 18:02:31');
INSERT INTO "synced" VALUES('bin/loop-stat','Lib/std/book-cmark/bin/loop-stat','7aa9da2bff17f69def4908f0cceef45ccb52819d','2016-01-02 18:02:31');
INSERT INTO "synced" VALUES('bin/stats','Lib/std/book-cmark/bin/stats','80c68f9626ed96fa5610694aa9ba9876b86b9f85','2015-12-30 15:42:34');
INSERT INTO "synced" VALUES('dat/STDprojnameDTS.sql','Lib/std/book-cmark/dat/STDprojnameDTS.sql','b51b9ee08973c1bd7cc2afc83bd9c8f7e38e95ec','2015-12-29 00:18:49');
INSERT INTO "synced" VALUES('index.md','Lib/std/book-cmark/index.md','b51b9ee08973c1bd7cc2afc83bd9c8f7e38e95ec','2015-12-29 00:18:49');
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
