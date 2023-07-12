--read committed (uncomitted)
--dirty read
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SAVEPOINT dirty;
UPDATE person SET balance = 100 WHERE name = 'Viktor';
SELECT pg_sleep(3);
ROLLBACK TO dirty;
COMMIT;
--dirty read
--non-repeatable read
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE person SET balance = 300 WHERE name = 'Viktor';
COMMIT;
--non-repeatable read
--read committed (uncomitted)

--repeatable read
--non-repeatable read
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
UPDATE person SET balance = 400 WHERE name = 'Viktor';
COMMIT;
--non-repeatable read
--phantom read
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
INSERT INTO person(name, balance) VALUES('Beylin', 0);
COMMIT;
--phantom read
--other anomalies
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
UPDATE person SET balance = balance + 5 WHERE id = 2;
SELECT pg_sleep(3);
SELECT * FROM person;
COMMIT;
--other anomalies
--repeatable read

--serializable
--phantom read
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
INSERT INTO person(name, balance) VALUES('Beylin', 0);
COMMIT;
--phantom read
--other anomalies
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE person SET balance = balance + 5 WHERE id = 2;
SELECT pg_sleep(3);
SELECT * FROM person;
COMMIT;
--other anomalies
--serializable