-- $Id$

select * from logg
    where koor <@ polygon(path('(
            (3.149,58.633),
            (3.163,52.395),
            (-6.437,49.364)
        )')) order by date;
