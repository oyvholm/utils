-- $Id$
-- File ID: 42ce10a4-fafb-11dd-b73a-000475e441b9

SELECT * FROM logg
    WHERE coor <@ polygon(path('(
            (58.633, 3.149),
            (52.395, 3.163),
            (49.364, -6.437)
        )')) ORDER BY date;
