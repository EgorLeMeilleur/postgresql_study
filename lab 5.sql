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
DECLARE
    data_type_ TEXT;
BEGIN
    UPDATE spec SET cur_max_value = cur_max_value + 1
                      WHERE table_name = table_name_ AND column_name = column_name_ RETURNING cur_max_value INTO _max_id;
    IF _max_id IS NULL THEN
        IF NOT EXISTS(SELECT * FROM information_schema.tables WHERE table_name = table_name_) THEN
        RAISE EXCEPTION 'Table % does not exist', table_name_;
        END IF;
        SELECT data_type FROM information_schema.columns WHERE table_name = table_name_ AND column_name = column_name_ INTO data_type_;
        IF data_type_ IS NULL THEN
            RAISE EXCEPTION 'Column % in table % does not exist', column_name_, table_name_;
        ELSEIF data_type_ <> 'integer' THEN
            RAISE EXCEPTION 'Column % in table % is not integer type', column_name_, table_name_;
        END IF;
        EXECUTE ('CREATE TRIGGER ' || get_trigger_name(table_name_, column_name_) || ' AFTER INSERT ON ' || quote_ident(table_name_)
            || ' REFERENCING NEW TABLE AS new_table' || ' FOR EACH STATEMENT EXECUTE FUNCTION update_spec_table ('
            || quote_literal(column_name_) || ')');
        EXECUTE ('CREATE TRIGGER ' || get_trigger_name(table_name_, column_name_) || ' AFTER UPDATE ON ' || quote_ident(table_name_)
            || ' REFERENCING NEW TABLE AS new_table' || ' FOR EACH STATEMENT EXECUTE FUNCTION update_spec_table ('
            || quote_literal(column_name_) || ')');
        EXECUTE  format('SELECT COALESCE(MAX(%s) + 1, 1) FROM %s', quote_ident(column_name_), quote_ident(table_name_)) INTO _max_id;
        INSERT INTO spec VALUES(trigger_next_integer_in_column('spec', 'id'), table_name_, column_name_, _max_id);
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION get_trigger_name(table_name_ TEXT, column_name_ TEXT, OUT trigger_name_ TEXT)
    LANGUAGE plpgsql AS $$
DECLARE
    trigger_count INT;
BEGIN
    SELECT COUNT(*) + 1 FROM information_schema.triggers WHERE event_object_table = table_name_ INTO trigger_count;
    trigger_name_ := quote_ident(table_name_ || '_' || column_name_ || '_' || trigger_count);
    IF EXISTS (SELECT triggers.trigger_name FROM information_schema.triggers WHERE triggers.trigger_name = trigger_name_
        AND triggers.event_object_table = table_name_) THEN
        trigger_name_ := quote_ident(trigger_name_ || '_' || gen_random_uuid());
    END IF;
END;
$$;

CREATE TABLE test (id INT);
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;
INSERT INTO test VALUES (10);
SELECT * FROM trigger_next_integer_in_column('test', 'id');
SELECT * FROM spec;
SELECT * FROM trigger_next_integer_in_column('teest', 'id');
SELECT * FROM trigger_next_integer_in_column('test', 'idd');
SELECT * FROM trigger_next_integer_in_column('teeeeeeest', 'iiiiiiiiid');
CREATE TABLE test1(id TEXT);
SELECT * FROM trigger_next_integer_in_column('test1', 'id');
SELECT trigger_name FROM information_schema.triggers;
DROP TABLE test;
DROP TABLE test1;

CREATE TABLE test2 (num1 INT, num2 INT);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
INSERT INTO test2 VALUES (10, 5);
SELECT * FROM trigger_next_integer_in_column('test2', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num2');
SELECT * FROM spec;
SELECT * FROM trigger_next_integer_in_column('t', 'num1');
SELECT * FROM trigger_next_integer_in_column('test2', 'num');
SELECT * FROM trigger_next_integer_in_column('teeeeeeest', 'iiiiiiiiid');
CREATE TABLE test3(id INT, txt TEXT);
SELECT * FROM trigger_next_integer_in_column('test3', 'id');
SELECT * FROM trigger_next_integer_in_column('test3','txt');
SELECT trigger_name FROM information_schema.triggers;
DROP TABLE test2;
DROP TABLE test3;

CREATE TABLE "my-table" ("column with space" INT);
SELECT * FROM trigger_next_integer_in_column('my-table', 'column with space');
INSERT INTO "my-table" VALUES (10);
SELECT * FROM trigger_next_integer_in_column('my-table', 'column with space');
SELECT * FROM trigger_next_integer_in_column('my-table', 'with space');
SELECT * FROM spec;

SELECT trigger_name FROM information_schema.triggers;
DROP TABLE "my-table";

CREATE FUNCTION test4_idd_3() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN END; $$;
CREATE TABLE test4(id INT, idd INT);
CREATE TRIGGER test4_id_2 AFTER DELETE ON test4 EXECUTE FUNCTION test4_idd_3();
SELECT * FROM trigger_next_integer_in_column('test4', 'id');
SELECT * FROM trigger_next_integer_in_column('test4', 'idd');
SELECT * FROM spec;
SELECT trigger_name FROM information_schema.triggers;
DROP TABLE test4;
DROP FUNCTION test4_idd_3;
DROP TABLE spec;
