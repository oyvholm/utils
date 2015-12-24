PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE config (
  name TEXT
    CONSTRAINT config_name_length
      CHECK (length(name) > 0)
    UNIQUE
    NOT NULL
  ,
  value JSON
    CONSTRAINT config_value_valid_json
      CHECK (json_valid(value))
    NOT NULL
);
INSERT INTO "config" VALUES('dbversion',1);
CREATE TABLE goal (
  begindate TEXT
    CONSTRAINT begindate_valid
      CHECK (datetime(begindate) IS NOT NULL)
    NOT NULL
  ,
  beginvalue REAL
  ,
  enddate TEXT
    CONSTRAINT enddate_valid
      CHECK (enddate IS NULL OR datetime(enddate) IS NOT NULL)
  ,
  endvalue REAL
);
INSERT INTO "goal" VALUES('STDbegintimeDTS',STDbeginvalueDTS,'STDendtimeDTS',STDendvalueDTS);
CREATE TABLE account (
  date TEXT
    CONSTRAINT date_valid
      CHECK (datetime(date) IS NOT NULL)
    NOT NULL
  ,
  current REAL
);
COMMIT;
