-- NB: Execute this file on a MonetDB database instance (mclient -l sql)!

DROP TABLE IF EXISTS master;
DROP TABLE IF EXISTS detail;

CREATE TABLE master(a int, b text, c int);
CREATE TABLE detail(a int, b text, c int);

INSERT INTO master(a,b,c)
  SELECT value, left(md5(value), 16), rand() % 10 + 1  -- 1:10 relationship
  FROM   generate_series(1, 11);

INSERT INTO detail(a,b,c)
  SELECT m.a, right(md5(m.a), 16), value
  FROM   master AS m, generate_series(1, 10)
  WHERE  value <= m.c;

-- SELECT *
-- FROM   master;

-- SELECT *
-- FROM   detail;

-----------------------------------------------------------------------

-- Query Q1
SELECT m.*
FROM   master AS m
WHERE  EXISTS (SELECT 1
               FROM   detail AS d
               WHERE  m.c = d.c
               AND    d.b >= 'a');


-- Query Q2
SELECT d.b AS b, d.a * 2 + d.a * 2 AS plus
FROM   detail AS d
WHERE  d.a * 2 > 15;
