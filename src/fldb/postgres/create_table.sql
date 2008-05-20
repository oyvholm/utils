-- $Id$

CREATE TABLE files (
    sha1 varchar(40),
    md5 varchar(32),
    crc32 varchar(8),
    size bigint,
    filename varchar,
    mtime timestamptz,
    ctime timestamptz,
    path varchar,
    inode bigint,
    device varchar,
    hostname varchar,
    uid varchar,
    gid varchar,
    perm varchar,
    lastver varchar(40),
    nextver varchar(40),
    descr varchar
);

CREATE TABLE other (
    kind varchar,
    sha1 varchar(40),
    md5 varchar(32),
    crc32 varchar(8),
    size bigint,
    filename varchar,
    symlink varchar,
    mtime timestamptz,
    ctime timestamptz,
    path varchar,
    inode bigint,
    device varchar,
    hostname varchar,
    uid varchar,
    gid varchar,
    perm varchar,
    lastver varchar(40),
    nextver varchar(40),
    descr varchar
);
