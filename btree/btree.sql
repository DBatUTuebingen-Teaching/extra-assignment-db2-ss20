DROP TABLE IF EXISTS playground;
CREATE TABLE playground (
  x int8 PRIMARY KEY,
  y int8
);

-- NB: column x is unique (key), column y contains duplicates
INSERT INTO playground(x,y)
  SELECT i AS x, i % 100 AS y
  FROM   generate_series(1,1000000) AS i;

-- Composite B+Tree over columns (x,y)
DROP INDEX IF EXISTS playground_x_y;
CREATE INDEX playground_x_y ON playground USING btree (x,y);

ANALYZE playground;

-- Enable pageinspect extension
CREATE EXTENSION IF NOT EXISTS pageinspect;

-----------------------------------------------------------------------

-- Auxiliary helper: convert (sub-)sequence of hex literals into their
-- decimal value:
--   data_to_numeric('0a 2a 10 ff', 1, 1) = 10          (= 0a₁₆)
--   data_to_numeric('0a 2a 10 ff', 2, 2) = 42          (= 2a₁₆)
--   data_to_numeric('0a 2a 10 ff', 1, 2) = 10762       (= 2a0a₁₆)
--   data_to_numeric('0a 2a 10 ff', 2, 3) = 4138        (= 102a₁₆)
--   data_to_numeric('0a 2a 10 ff', 1, 4) = 4279249418  (= ff102a0a₁₆)
DROP FUNCTION data_to_numeric(text, int, int);
CREATE FUNCTION data_to_numeric(data text, s int, e int)
RETURNS numeric AS
$$
  SELECT SUM((get_byte(decode(a.v, 'hex'), 0) :: bigint) *
             (2^(8*(a.i - s))) :: bigint)
  FROM   unnest(string_to_array(data, ' ')) WITH ORDINALITY AS a(v,i)
  WHERE  i BETWEEN s AND e;
$$ LANGUAGE SQL;

