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

INSERT INTO person(username, password) VALUES ('Ivan', '2003');
INSERT INTO person(username, password) VALUES ('Viktor', '2004');
INSERT INTO person(username, password) VALUES ('David', '2005');

INSERT INTO product(name, price) VALUES ('honor', 100);
INSERT INTO product(name, price) VALUES ('lada granta', 200);
INSERT INTO product(name, price) VALUES ('macbook 14 m2 pro', 150);

INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(1, 1, '2017-04-05');
INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(1, 1, '2017-04-06');
INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(2, 2, '2018-04-04');
INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(3, 3, '2019-10-10');
INSERT INTO purchase(PERSON_ID, PRODUCT_ID, PURCHASE_DATE) VALUES(1, 1, '2019-10-10');


CREATE OR REPLACE VIEW person_product AS
    SELECT person.username, person.password, product.name, product.price, purchase_date FROM
           person JOIN purchase ON person.id = purchase.person_id JOIN product ON product.id = purchase.product_id;

CREATE OR REPLACE FUNCTION insert_person_product_f() RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    person_id_ INT;
    product_id_ INT;
BEGIN
    SELECT id FROM person WHERE username = new.username AND password = new.password INTO person_id_;
    IF person_id_ IS NULL
        THEN INSERT INTO person(username, password) VALUES(new.username, new.password) RETURNING id INTO person_id_;
    END IF;
    SELECT id FROM product WHERE name = new.name AND price = new.price INTO product_id_;
    IF product_id_ IS NULL
        THEN INSERT INTO product(name, price) VALUES(new.name, new.price) RETURNING id INTO product_id_;
    END IF;
    INSERT INTO purchase(person_id, product_id, purchase_date) VALUES(person_id_, product_id_, new.purchase_date);
    RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER insert_person_product INSTEAD OF INSERT ON person_product FOR EACH ROW EXECUTE FUNCTION insert_person_product_f();


CREATE OR REPLACE FUNCTION update_person_product_f() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    UPDATE purchase SET purchase_date = new.purchase_date
                    WHERE person_id = (SELECT id FROM person WHERE username = old.username AND password = old.password)
    AND product_id = (SELECT id FROM product WHERE name = old.name AND price = old.price) AND purchase_date = old.purchase_date;
    RETURN NEW;
END;
$$;
CREATE OR REPLACE TRIGGER update_person_product INSTEAD OF UPDATE ON person_product FOR EACH ROW EXECUTE FUNCTION update_person_product_f();


CREATE OR REPLACE FUNCTION delete_person_product_f() RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM purchase WHERE person_id = (SELECT id FROM person WHERE username = old.username AND password = old.password)
    AND product_id = (SELECT id FROM product WHERE name = old.name AND price = old.price) AND purchase_date = old.purchase_date;
    RETURN OLD;
END;
$$;
CREATE OR REPLACE TRIGGER delete_person_product INSTEAD OF DELETE ON person_product FOR EACH ROW EXECUTE FUNCTION delete_person_product_f();

SELECT * FROM person;
SELECT * FROM product;
SELECT * FROM purchase;
SELECT * FROM person_product;

INSERT INTO person_product(username, password, name, price, purchase_date) VALUES ('Egor', '2002', 'BMX', 100, '2000-10-01');
SELECT * FROM person;
SELECT * FROM product;
SELECT * FROM purchase;
SELECT * FROM person_product;
INSERT INTO person_product(username, password, name, price, purchase_date) VALUES ('Egor', '2003', 'BMX', 100, '2012-10-01');
SELECT * FROM person;
SELECT * FROM product;
SELECT * FROM purchase;
SELECT * FROM person_product;
INSERT INTO person_product(username, password, name, price, purchase_date) VALUES ('Egor', '2002', 'BMX', 150, '2012-10-01');
SELECT * FROM person;
SELECT * FROM product;
SELECT * FROM purchase;
SELECT * FROM person_product;
INSERT INTO person_product(username, password, name, price, purchase_date) VALUES ('Egor', '2002', 'BMX', 150, '1998-11-01');
SELECT * FROM person;
SELECT * FROM product;
SELECT * FROM purchase;
SELECT * FROM person_product;
INSERT INTO person_product(username, password, name, price, purchase_date) VALUES ('Egor', '2002', 'BMX', 150, '1998-11-01');
SELECT * FROM person;
SELECT * FROM product;
SELECT * FROM purchase;
SELECT * FROM person_product;

UPDATE person_product SET purchase_date = '1700-10-10' WHERE username = 'Egor' AND password = '2003';
SELECT * FROM person_product;
SELECT * FROM purchase;
UPDATE person_product SET purchase_date = '2023-01-01' WHERE name = 'BMX' AND price = 100;
SELECT * FROM person_product;
SELECT * FROM purchase;
UPDATE person_product SET purchase_date = '2023-02-01' WHERE purchase_date = '2019-10-10';
SELECT * FROM person_product;
SELECT * FROM purchase;
UPDATE person_product SET purchase_date = '1999-09-09' WHERE name = 'fffff';
SELECT * FROM person_product;
SELECT * FROM purchase;

DELETE FROM person_product WHERE purchase_date = '2019-10-10';
SELECT * FROM person_product;
SELECT * FROM purchase;
DELETE FROM person_product WHERE purchase_date = '2017-04-05';
SELECT * FROM person_product;
SELECT * FROM purchase;
DELETE FROM person_product WHERE name = 'BMX' AND price = 150;
SELECT * FROM person_product;
SELECT * FROM purchase;
DELETE FROM person_product WHERE name = 'honor';
SELECT * FROM person_product;
SELECT * FROM purchase;
DELETE FROM person_product WHERE username = 'David';
SELECT * FROM person_product;
SELECT * FROM purchase;
DELETE FROM person_product WHERE username = 'Egor' AND password = '2003';
SELECT * FROM person_product;
SELECT * FROM purchase;
SELECT * FROM person;
SELECT * FROM product;

DROP TABLE person CASCADE;
DROP TABLE product CASCADE;
DROP TABLE purchase;
DROP FUNCTION update_person_product_f();
DROP FUNCTION delete_person_product_f();
DROP FUNCTION insert_person_product_f();
