CREATE TABLE IF NOT EXISTS T (
    id INTEGER PRIMARY KEY,
    abc TEXT,
    tf INTEGER,
    num INTEGER
)

INSERT INTO T (abc, tf, num)
VALUES
    ('x', 1, 10),
    ('y', 1, 40),
    ('x', 0, 30),
    ('y', 0, 20),
    ('x', 1, NULL);


SELECT t.*
FROM T AS t;

pragma table_info(T)


select
    f.YOY_Sales,
    typeof(f.YOY_Sales) as type,
    replace(f.YOY_Sales, '%', '') as rmpc,                                  -- remove percent sign
    typeof(replace(f.YOY_Sales, '%', '')) as type,
    replace(f.YOY_Sales, '%', '')/100 as rmpc_dint,                         -- divide by an integer
    typeof(replace(f.YOY_Sales, '%', '')/100) as type,
    replace(f.YOY_Sales, '%', '')/100.0 as rmpc_dreal,                      -- divide by a float
    typeof(replace(f.YOY_Sales, '%', '')/100.0) as type,
    cast(replace(f.YOY_Sales, '%', '')/100.0 as real) rmpc_dreal_cast,      -- change type
    typeof(cast(replace(f.YOY_Sales, '%', '')/100.0 as real)) as type
from future50_raw f

/*
Stage dividing by integer was sufficient to turn some into real
possible case where int/int gives int, want real
/100.0 int/real = real, then cast() for explicitness, cover all cases
*/

-- renameing cols before inserting into schema made no difference
