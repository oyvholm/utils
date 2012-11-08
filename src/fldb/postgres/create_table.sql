-- $Id$
-- File ID: 98ed2ea2-fa5b-11dd-9ad8-000475e441b9

CREATE TABLE files (
    id bigserial PRIMARY KEY,
    idate timestamptz DEFAULT now(),
    sha1 varchar(40),
    gitsum varchar(40),
    md5 varchar(32),
    crc32 varchar(8),
    size bigint,
    filename varchar,
    mtime timestamptz,
    ctime timestamptz,
    path varchar,
    inode bigint,
    links integer,
    device varchar,
    hostname varchar,
    uid varchar,
    gid varchar,
    perm varchar,
    lastver varchar(40),
    nextver varchar(40),
    descr varchar,
    latin1 boolean
);
