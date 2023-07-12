CREATE OR REPLACE FUNCTION create_audit() RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
    tables CURSOR FOR (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public');
    table_name_ TEXT;
    table_name_audit TEXT;
BEGIN
    OPEN tables;
    LOOP
        FETCH tables INTO table_name_;
        EXIT WHEN NOT FOUND;
        table_name_audit := quote_ident(table_name_ || '_audit');
        EXECUTE 'CREATE TABLE ' || table_name_audit || ' AS SELECT * FROM ' || quote_ident(table_name_);
        EXECUTE 'ALTER TABLE ' || table_name_audit || ' ADD COLUMN modified_at TIMESTAMP DEFAULT current_timestamp';
        EXECUTE 'ALTER TABLE ' || table_name_audit || ' ADD COLUMN modified_by TEXT DEFAULT current_user';
        EXECUTE 'ALTER TABLE ' || table_name_audit || ' ADD COLUMN modified_with TEXT DEFAULT ''COPY'' ';

        EXECUTE 'CREATE OR REPLACE FUNCTION ' || quote_ident(table_name_ || '_audit_insert') || '() RETURNS TRIGGER AS $BODY$ BEGIN ' ||
        'INSERT INTO ' || table_name_audit || ' SELECT *, current_timestamp, current_user, ''INSERT'' FROM new_table; ' ||
                'RETURN NULL; END; $BODY$ LANGUAGE plpgsql';
        EXECUTE 'CREATE OR REPLACE TRIGGER ' || quote_ident(table_name_ || '_audit_insert_trigger') || ' AFTER INSERT ON ' ||
            quote_ident(table_name_) || ' REFERENCING NEW TABLE AS new_table FOR EACH STATEMENT EXECUTE FUNCTION '
                    || quote_ident(table_name_ || '_audit_insert') || '()';

        EXECUTE 'CREATE OR REPLACE FUNCTION ' || quote_ident(table_name_ || '_audit_delete') || '() RETURNS TRIGGER AS $BODY$ BEGIN ' ||
        'INSERT INTO ' || table_name_audit || ' SELECT *, current_timestamp, current_user, ''DELETE'' FROM old_table; ' ||
                'RETURN NULL; END; $BODY$ LANGUAGE plpgsql';
        EXECUTE 'CREATE OR REPLACE TRIGGER ' || quote_ident(table_name_ || '_audit_delete_trigger') || ' AFTER DELETE ON ' ||
            quote_ident(table_name_) || ' REFERENCING OLD TABLE AS old_table FOR EACH STATEMENT EXECUTE FUNCTION '
                    || quote_ident(table_name_ || '_audit_delete') || '()';

        EXECUTE 'CREATE OR REPLACE FUNCTION ' || quote_ident(table_name_ || '_audit_update') || '() RETURNS TRIGGER AS $BODY$ BEGIN ' ||
        'INSERT INTO ' || table_name_audit || ' SELECT *, current_timestamp, current_user, ''UPDATE'' FROM new_table; ' ||
                 'RETURN NULL; END; $BODY$ LANGUAGE plpgsql';
        EXECUTE 'CREATE OR REPLACE TRIGGER ' || quote_ident(table_name_ || '_audit_update_trigger') || ' AFTER UPDATE ON ' ||
            quote_ident(table_name_) || ' REFERENCING NEW TABLE AS new_table FOR EACH STATEMENT EXECUTE FUNCTION '
                    || quote_ident(table_name_ || '_audit_update') || '()';
    END LOOP;
    CLOSE tables;
END;
$$;

CREATE TABLE "my-table"("column with spaces" TEXT);
INSERT INTO "my-table" VALUES('p');


SELECT * FROM create_audit();

INSERT INTO band(name, members_quantity, foundation_date) VALUES('LOOOOOL', 5, '2012-01-03');
SELECT * FROM band_audit;
UPDATE band SET members_quantity = 4 WHERE name = 'LOOOOOL';
SELECT * FROM band_audit;
DELETE FROM band WHERE name = 'LOOOOOL';
SELECT * FROM band_audit;
INSERT INTO band(name, members_quantity, foundation_date) VALUES('LOOOL', 6, '2012-01-03');
SELECT * FROM band_audit;

INSERT INTO band(name, members_quantity, foundation_date) VALUES('llll', 5, '2012-01-03');
SELECT * FROM band_audit;
UPDATE band SET members_quantity = 3 WHERE name = 'llll';
SELECT * FROM band_audit;
DELETE FROM band WHERE name = 'llll';
SELECT * FROM band_audit;
INSERT INTO band(name, members_quantity, foundation_date) VALUES('llll', 6, '2012-01-03');
SELECT * FROM band_audit;

SET ROLE admin;

INSERT INTO band(name, members_quantity, foundation_date) VALUES('RRRRRR', 5, '2011-01-03');
SELECT * FROM band_audit;
UPDATE band SET members_quantity = 4 WHERE name = 'Scorpions';
SELECT * FROM band_audit;
DELETE FROM band WHERE name = 'RRRRRR';
SELECT * FROM band_audit;
INSERT INTO band(name, members_quantity, foundation_date) VALUES('Scorpions', 5, '1965-06-01');
SELECT * FROM band_audit;

SET ROLE postgres;

INSERT INTO album(name, songs_quantity, band_id, release_date) VALUES('l', 4, 3, '2020-01-01');
SELECT * FROM album_audit;
UPDATE album SET songs_quantity = 3 WHERE name = 'l';
SELECT * FROM album_audit;
DELETE FROM album WHERE name = 'l';
SELECT * FROM album_audit;

INSERT INTO "my-table" VALUES('9');
DELETE FROM "my-table" WHERE "column with spaces" = '9';
UPDATE "my-table" SET "column with spaces" = 'Q' WHERE "column with spaces" = 'p';


DROP FUNCTION create_audit();
DROP TABLE song_audit;
DROP TABLE band_audit;
DROP TABLE album_audit;
DROP TABLE "my-table_audit";
DROP TABLE "my-table";