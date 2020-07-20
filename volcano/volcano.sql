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

-- :MANY = |many|
SELECT COUNT(*) AS "MANY" FROM many;
\gset

-- Configure for timing experiments
\set ON_ERROR_ROLLBACK interactive
\timing on


-- Query Q1
SELECT m.*
FROM   many AS m
OFFSET :MANY - 10;


-- Query Q2
SELECT o.a, m.*
FROM   generate_series(2,4) AS o(a),
       LATERAL (SELECT m.*
                FROM   many AS m
                OFFSET :MANY - o.a) AS m;


-- Query Q3
SELECT m.c, SUM(m.a) AS agg
FROM   many AS m
GROUP BY m.c;


-----------------------------------------------------------------------

-- Query Q4
SELECT EXISTS(TABLE many);


-- Query Q5
SELECT (SELECT COUNT(*) FROM many) > 0;
