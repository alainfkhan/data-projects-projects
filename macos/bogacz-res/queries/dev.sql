CREATE TABLE IF NOT EXISTS T (
    id INTEGER PRIMARY KEY,
    abc TEXT,
    tf INTEGER,
    num INTEGER
);

INSERT INTO T (abc, tf, num)
VALUES
('x', 1, 10),
('y', 1, 40),
('x', 0, 30),
('y', 0, 20),
('x', 1, NULL);


SELECT t.*
FROM T AS t;

PRAGMA table_info (T);


SELECT
    f.YOY_Sales,
    TYPEOF(f.YOY_Sales) AS Type,
    REPLACE(f.YOY_Sales, '%', '') AS Rmpc,                                      -- remove percent sign
    TYPEOF(REPLACE(f.YOY_Sales, '%', '')) AS Type,
    REPLACE(f.YOY_Sales, '%', '') / 100 AS Rmpc_Dint,                           -- divide by an integer
    TYPEOF(REPLACE(f.YOY_Sales, '%', '') / 100) AS Type,
    REPLACE(f.YOY_Sales, '%', '') / 100.0 AS Rmpc_Dreal,                        -- divide by a float
    TYPEOF(REPLACE(f.YOY_Sales, '%', '') / 100.0) AS Type,
    CAST(REPLACE(f.YOY_Sales, '%', '') / 100.0 AS REAL) AS Rmpc_Dreal_Cast,     -- change type
    TYPEOF(CAST(REPLACE(f.YOY_Sales, '%', '') / 100.0 AS REAL)) AS Type
FROM future50_raw AS f;

/*
Stage dividing by integer was sufficient to turn some into real
possible case where int/int gives int, want real
/100.0 int/real = real, then cast() for explicitness, cover all cases
*/

-- renameing cols before inserting into schema made no difference
