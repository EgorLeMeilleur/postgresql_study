CREATE TABLE spec_table (
    id INT NOT NULL PRIMARY KEY,
    table_name VARCHAR NOT NULL,
    column_name VARCHAR NOT NULL,
    cur_max_value INT NOT NULL,
    UNIQUE (table_name, column_name)
);

INSERT INTO spec_table VALUES(1, 'spec', 'id', 1);

CREATE OR REPLACE FUNCTION next_integer_in_column(_table_name VARCHAR, _column_name VARCHAR, out _max_id INT)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS
$$
BEGIN
    UPDATE spec_table SET cur_max_value = cur_max_value + 1 WHERE table_name = _table_name AND column_name = _column_name RETURNING cur_max_value INTO _max_id;
    IF _max_id IS NULL THEN
        EXECUTE  format('SELECT COALESCE(MAX(%s) + 1, 1) FROM %s', QUOTE_IDENT(_column_name), QUOTE_IDENT(_table_name)) INTO _max_id;
        INSERT INTO spec_table VALUES (next_integer_in_column('spec', 'id'), _table_name, _column_name, _max_id);
    END IF;
END;
$$;

SELECT next_integer_in_column('spec', 'id');
SELECT * FROM spec_table;
SELECT next_integer_in_column('spec', 'id');
SELECT * FROM spec_table;

CREATE TABLE test
(
    id integer NOT NULL
);

INSERT into test VALUES (10);
SELECT next_integer_in_column('test', 'id');
SELECT * FROM test;
SELECT * FROM spec_table;
SELECT next_integer_in_column('test', 'id');
SELECT * FROM spec_table;

CREATE TABLE test2
(
    num_value1 integer NOT NULL,
    num_value2 integer NOT NULL
);

SELECT next_integer_in_column('test2', 'num_value1');
SELECT * FROM spec_table;
SELECT next_integer_in_column('test2', 'num_value1');
SELECT * FROM spec_table;

INSERT INTO test2 VALUES (2, 13);
SELECT next_integer_in_column('test2', 'num_value2');
SELECT * FROM spec_table;

SELECT next_integer_in_column('test2', 'num_value1');
SELECT next_integer_in_column('test2', 'num_value1');
SELECT next_integer_in_column('test2', 'num_value1');
SELECT next_integer_in_column('test2', 'num_value1');
SELECT next_integer_in_column('test2', 'num_value1');
SELECT * FROM spec_table;

SELECT * FROM test2;
INSERT INTO test2 VALUES (20, 130);

DROP FUNCTION next_integer_in_column(_table_name varchar, _column_name varchar);
DROP TABLE spec_table;
DROP TABLE test;
DROP TABLE test2;