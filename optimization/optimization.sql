DROP TABLE IF EXISTS one;
DROP TABLE IF EXISTS many;

CREATE TABLE one  (a int NOT NULL, b text, c int);
CREATE TABLE many (a int NOT NULL, b text, c int NOT NULL);

INSERT INTO one(a,b,c)
  SELECT i, left(md5(i::text), 16), random() * (10000 + 1)  -- 1:10000 relationship
  FROM   generate_series(1, 100) AS i;

INSERT INTO many(a,b,c)
  SELECT o.a, right(md5(o.a::text), 16), i
  FROM   one AS o, LATERAL generate_series(0, o.c - 1) AS i;

ANALYZE one;
ANALYZE many;
