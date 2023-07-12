CREATE TABLE person (
    id SERIAL PRIMARY KEY,
    username TEXT NOT NULL,
    password TEXT NOT NULL,
    UNIQUE(username, password)
);

CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price INT NOT NULL,
    UNIQUE(name, price)
);

CREATE TABLE purchase (
    person_id INT REFERENCES person(id),
    product_id INT REFERENCES product(id),
    purchase_date DATE NOT NULL,
    UNIQUE(person_id, product_id, purchase_date)
);

INSERT INTO person(username, password) VALUES ('ivan', '2003');
INSERT INTO person(username, password) VALUES ('viktor', '2004');
INSERT INTO person(username, password) VALUES ('david', '2005');

INSERT INTO product(name, price) VALUES ('honor', 100);
INSERT INTO product(name, price) VALUES ('lada granta', 200);
INSERT INTO product(name, price) VALUES ('macbook 14 m2 pro', 150);

INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(1, 1, '2017-04-05');
INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(1, 1, '2017-04-06');
INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(2, 2, '2018-04-04');
INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(3, 3, '2019-10-10');
INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(1, 1, '2019-10-10');

CREATE ROLE admin SUPERUSER;
SET ROLE admin;
CREATE ROLE owner;
CREATE ROLE supplier;
CREATE ROLE buyer;
CREATE ROLE analyst;

GRANT INSERT, SELECT, UPDATE, DELETE ON person, product, purchase TO owner;
GRANT USAGE, SELECT ON SEQUENCE person_id_seq TO owner;
GRANT INSERT, SELECT, UPDATE ON product TO supplier;
GRANT USAGE, SELECT ON SEQUENCE product_id_seq TO supplier, owner;
GRANT SELECT ON product TO buyer, analyst;
GRANT INSERT ON purchase to buyer;
GRANT SELECT ON purchase TO analyst, buyer;
GRANT SELECT ON person TO analyst, buyer;
GRANT SELECT ON SEQUENCE product_id_seq TO analyst;
GRANT SELECT ON SEQUENCE person_id_seq TO analyst;
ALTER TABLE purchase ENABLE ROW LEVEL SECURITY;
ALTER TABLE person ENABLE ROW LEVEL SECURITY;
CREATE POLICY purchases_of_person ON purchase TO buyer USING
    (EXISTS (SELECT 1 FROM person WHERE id = purchase.person_id AND username = current_user));
CREATE POLICY name_of_person ON person FOR SELECT TO buyer USING
    (current_user = username);

CREATE USER Ivan;
CREATE USER Viktor;
GRANT buyer TO Ivan, viktor;

SET ROLE owner;
INSERT INTO person(username, password) VALUES('DAVID', 'DAVID');
INSERT INTO product(name, price) VALUES('david', 0);
INSERT INTO purchase VALUES(2, 2, '1900-01-01');
UPDATE product SET price = 300 WHERE name = 'honor';
UPDATE person SET password = '300' WHERE username = 'DAVID';
UPDATE purchase SET purchase_date = '1900-01-02' WHERE purchase_date = '1900-01-01';
DELETE FROM purchase WHERE purchase_date = '2018-04-04';
DELETE FROM person WHERE username = 'DAVID';
DELETE FROM product WHERE price = 0;
SELECT * FROM purchase;
SELECT * FROM product;
SELECT * FROM person;
DROP TABLE purchase;

SET ROLE buyer;
SET ROLE Ivan;
INSERT INTO person(username, password) VALUES('vanya', 'DAVID');
INSERT INTO purchase VALUES(1, 1, '1912-07-01');
INSERT INTO purchase VALUES(1, 1, '1912-07-01');
DELETE FROM purchase WHERE purchase_date = '1912-07-01';
SELECT * FROM product;
SELECT * FROM purchase;
SELECT * FROM person;
SET ROLE Viktor;
INSERT INTO person(username, password) VALUES('vanya', 'DAVID');
INSERT INTO purchase VALUES(1, 1, '1912-07-01');
INSERT INTO purchase VALUES(2, 1, '1912-07-01');
DELETE FROM purchase WHERE purchase_date = '1912-07-01';
SELECT * FROM product;
SELECT * FROM purchase;
SELECT CURRENT_USER;

SET ROLE analyst;
SELECT * FROM purchase;
UPDATE purchase set purchase_date = '1900-01-01' WHERE product_id = 1;
SELECT * FROM product;
SELECT * FROM person;
DELETE FROM person WHERE id = 1;

SET ROLE supplier;
INSERT INTO product(name, price) VALUES('vanya', 500);
UPDATE product SET price = 1000 WHERE name = 'vanya';
DELETE FROM product WHERE name = 'vanya';
SELECT * FROM product;

SET ROLE admin;
DROP POLICY purchases_of_person ON purchase;
DROP POLICY name_of_person ON person;
DROP TABLE purchase;
DROP TABLE product;
DROP TABLE person;
DROP ROLE supplier;
DROP ROLE buyer;
DROP ROLE analyst;
DROP ROLE owner;
SET ROLE postgres;
DROP ROLE admin;
DROP ROLE Ivan;
DROP ROLE Viktor;
