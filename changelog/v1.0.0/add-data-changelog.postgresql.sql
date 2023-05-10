--liquibase formatted sql

--changeset nikita.ryadnov:1
INSERT INTO clients(id, name, discount_1, discount_2) VALUES (1, 'Kate', 3, 10);
INSERT INTO clients(id, name, discount_1, discount_2) VALUES (2, 'Nik', 2, 8);
INSERT INTO clients(id, name, discount_1, discount_2) VALUES (3, 'Jane', 4, 6);
SELECT SETVAL('clients_id_seq', (SELECT MAX(id) FROM clients));
--changeset nikita.ryadnov:2
INSERT INTO products (id, name, price, description, average_rating) VALUES (1, 'table', 1500.00, 'table_description', null);
INSERT INTO products (id, name, price, description, average_rating) VALUES (2, 'chair', 999.99, 'chair_description', null);
SELECT SETVAL('products_id_seq', (SELECT MAX(id) FROM products));
--changeset nikita.ryadnov:3
INSERT INTO ratings (id, product_id, client_id, rating) VALUES (1, 1, 1, 5);
INSERT INTO ratings (id, product_id, client_id, rating) VALUES (2, 1, 2, 2);
INSERT INTO ratings (id, product_id, client_id, rating) VALUES (3, 1, 3, 1);
INSERT INTO ratings (id, product_id, client_id, rating) VALUES (4, 2, 1, 3);
SELECT SETVAL('ratings_id_seq', (SELECT MAX(id) FROM ratings));