-- $Id$

SELECT * FROM logg
    WHERE coor <@ polygon(path('(
            (58.633, 3.149),
            (52.395, 3.163),
            (49.364, -6.437)
        )')) ORDER BY date;
