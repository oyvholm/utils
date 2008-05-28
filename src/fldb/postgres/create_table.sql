-- $Id$

CREATE TABLE files (
    id bigserial PRIMARY KEY,
    idate timestamptz DEFAULT now(),
    sha1 varchar(40),
    md5 varchar(32),
    crc32 varchar(8),
    size bigint,
    filename varchar,
    mtime timestamptz,
    ctime timestamptz,
    calctime real,
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
