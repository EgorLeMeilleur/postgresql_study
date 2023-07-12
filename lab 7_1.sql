CREATE TABLE person(
  id SERIAL PRIMARY KEY,
  name TEXT,
  balance INT
);

INSERT INTO person(name, balance) VALUES('David', 0);
INSERT INTO person(name, balance) VALUES('Ivan', 100);
INSERT INTO person(name, balance) VALUES('Viktor', 200);

--read committed (uncomitted)
--dirty read
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM person WHERE name = 'Viktor';
COMMIT;
--dirty read
--non-repeatable read
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT balance FROM person WHERE name = 'Viktor';
SELECT pg_sleep(3);
SELECT balance FROM person WHERE name = 'Viktor';
COMMIT;
--non-repeatable read
--read committed (uncomitted)

--repeatable read
--non-repeatable read
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT balance FROM person WHERE name = 'Viktor';
SELECT pg_sleep(3);
SELECT balance FROM person WHERE name = 'Viktor';
COMMIT;
--non-repeatable read
--phantom read
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM person WHERE balance = 0;
SELECT pg_sleep(3);
SELECT * FROM person WHERE balance = 0;
COMMIT;
SELECT * FROM person WHERE balance = 0;
--phantom read
--other anomalies
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
UPDATE person SET balance = balance - 5 WHERE id = 3;
SELECT pg_sleep(3);
SELECT * FROM person;
COMMIT;
select * from person;
--other anomalies
--repeatable read

--serializable
--phantom read
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM person WHERE balance = 0;
SELECT pg_sleep(3);
SELECT * FROM person WHERE balance = 0;
COMMIT;
--phantom read
--other anomalies
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE person SET balance = balance - 5 WHERE id = 3;
SELECT pg_sleep(3);
SELECT * FROM person;
COMMIT;
--other anomalies
--serializable

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SAVEPOINT IVAN;
UPDATE person SET balance = 0 WHERE name = 'Ivan';
SELECT * FROM person;
ROLLBACK TO IVAN;
SELECT * FROM person;
COMMIT;

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SAVEPOINT delete;
DELETE FROM person WHERE name = 'Ivan';
ROLLBACK TO delete;
COMMIT;
SELECT * FROM person;

DROP TABLE person;