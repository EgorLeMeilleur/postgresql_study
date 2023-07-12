CREATE TABLE spec(
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    cur_max_value INTEGER NOT NULL,
    UNIQUE(table_name, column_name)
);

INSERT INTO spec VALUES (1, 'spec', 'id', 1);

CREATE OR REPLACE FUNCTION update_spec_table()
    RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    max_value INT;
BEGIN
    EXECUTE format('SELECT MAX(%s) FROM new_table', quote_ident(tg_argv[0])) INTO max_value;
    UPDATE spec SET cur_max_value = max_value WHERE table_name = tg_table_name AND column_name = tg_argv[0] AND max_value > cur_max_value;
    RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION trigger_next_integer_in_column(table_name_ TEXT, column_name_ TEXT, OUT _max_id INT)
    LANGUAGE plpgsql AS $$
BEGIN
    UPDATE spec SET cur_max_value = cur_max_value + 1
                      WHERE table_name = table_name_ AND column_name = column_name_ RETURNING cur_max_value INTO _max_id;
    IF _max_id IS NULL THEN
        EXECUTE  format('SELECT COALESCE(MAX(%s) + 1, 1) FROM %s', quote_ident(column_name_), quote_ident(table_name_)) INTO _max_id;
        EXECUTE ('CREATE OR REPLACE TRIGGER ' || quote_ident(table_name_ || '_' || column_name_ || '_insert')
                     || ' AFTER INSERT ON ' || quote_ident(table_name_) || ' REFERENCING NEW TABLE AS new_table' ||
                     ' FOR EACH STATEMENT EXECUTE FUNCTION update_spec_table ('
                     || quote_literal(column_name_) || ')');
        EXECUTE ('CREATE OR REPLACE TRIGGER ' || quote_ident(table_name_ || '_' || column_name_ || '_update')
                     || ' AFTER UPDATE ON ' || quote_ident(table_name_) || ' REFERENCING NEW TABLE AS new_table' ||
                     ' FOR EACH STATEMENT EXECUTE FUNCTION update_spec_table ('
                     || quote_literal(column_name_) || ')');
        INSERT INTO spec VALUES(trigger_next_integer_in_column('spec', 'id'), table_name_, column_name_, _max_id);
    END IF;
END;
$$;

CREATE TABLE test (id INT);
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;
INSERT INTO test VALUES (0);
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;
INSERT INTO test VALUES (10);
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;
INSERT INTO test VALUES (5), (15);
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;
INSERT INTO test VALUES (1), (2);
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;
INSERT INTO test VALUES (20), (30);
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;
UPDATE test SET id = 2 * id;
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;
UPDATE test SET id = 1;
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;

CREATE TABLE test2(num1 INT, num2 INT);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
INSERT INTO test2(num1) VALUES (3);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
INSERT INTO test2(num1) VALUES (2);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
INSERT INTO test2(num2) VALUES (5);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
INSERT INTO test2(num2) VALUES (3);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
INSERT INTO test2 VALUES (1, 10);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
INSERT INTO test2 VALUES (2, 2);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
INSERT INTO test2 VALUES (20, 21);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
UPDATE test2 SET num1 = 30;
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
UPDATE test2 set num1 = 32;
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
UPDATE test2 SET num2 = 45;
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
UPDATE test2 set num2 = 15;
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
UPDATE test2 set num1 = 70, num2 = 10;
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
UPDATE test2 set num1 = 10, num2 = 7;
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
UPDATE test2 set num1 = 150, num2 = 200;
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;

CREATE TABLE "my-table" ("column with space" INT);
SELECT * FROM trigger_next_integer_in_column('my-table', 'column with space');
INSERT INTO "my-table" VALUES (10);
SELECT * FROM trigger_next_integer_in_column('my-table', 'column with space');
SELECT * FROM spec;

DROP TABLE spec;
DROP TABLE test;
DROP TABLE test2;
DROP TABLE "my-table";