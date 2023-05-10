--liquibase formatted sql

--changeset nikita.ryadnov:1
CREATE TABLE IF NOT EXISTS clients
(
    id         BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name       VARCHAR(40) NOT NULL UNIQUE,
    discount_1 INTEGER     NOT NULL DEFAULT 0 CHECK (discount_1 >= 0 AND discount_1 <= 100),
    discount_2 INTEGER     NOT NULL DEFAULT 0 CHECK (discount_1 >= 0 AND discount_1 <= 100)
)
--changeset nikita.ryadnov:2
CREATE TABLE IF NOT EXISTS products
(
    id             BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name           VARCHAR(40)    NOT NULL UNIQUE,
    price          NUMERIC(12, 2) NOT NULL,
    description    VARCHAR(500),
    average_rating DECIMAL CHECK (average_rating >= 1.0 AND average_rating <= 5.0) DEFAULT NULL
)
--changeset nikita.ryadnov:3
CREATE TABLE IF NOT EXISTS ratings
(
    id         BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    product_id BIGINT NOT NULL REFERENCES products (id) ON DELETE CASCADE,
    client_id  BIGINT NOT NULL REFERENCES clients (id) ON DELETE SET NULL,
    rating     INTEGER CHECK (rating >= 1 AND rating <= 5) DEFAULT NULL,
    CONSTRAINT unique_product_id_and_client_id UNIQUE (product_id, client_id)
)
--changeset nikita.ryadnov:4 splitStatements:false
create function rating_insert_or_update_trigger_function() RETURNS TRIGGER
AS
$$
BEGIN
    IF (TG_OP = 'DELETE')
    THEN
        UPDATE products
        SET average_rating=(SELECT AVG(CAST(rating as DECIMAL)) FROM ratings WHERE product_id = OLD.product_id)
        WHERE id = OLD.product_id;
    ELSE
        UPDATE products
        SET average_rating=(SELECT AVG(CAST(rating as DECIMAL)) FROM ratings WHERE product_id = NEW.product_id)
        WHERE id = NEW.product_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
--changeset nikita.ryadnov:5
CREATE TRIGGER update_average_rating
    AFTER UPDATE OR INSERT OR DELETE
    ON ratings
    FOR EACH ROW
EXECUTE FUNCTION rating_insert_or_update_trigger_function()
--changeset nikita.ryadnov:6
CREATE TABLE IF NOT EXISTS sales
(
    id           BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    client_id    BIGINT                      NOT NULL REFERENCES clients (id) ON DELETE SET NULL,
    date_of_sale TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    cheque       INTEGER                     NOT NULL
)
--changeset nikita.ryadnov:7
CREATE TABLE IF NOT EXISTS positions
(
    id             BIGINT PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    sale_id        BIGINT  NOT NULL REFERENCES sales (id),
    product_id     BIGINT  NOT NULL REFERENCES products (id),
    quantity       INTEGER NOT NULL,
    initial_price  NUMERIC(12, 2) CHECK (initial_price > 0),
    final_price    NUMERIC(12, 2) CHECK (final_price > 0),
    final_discount INTEGER NOT NULL DEFAULT 0 CHECK (final_discount >= 0 AND final_discount <= 100)
)
--changeset nikita.ryadnov:8
CREATE TABLE IF NOT EXISTS global_discount
(
    id             BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    product_id     BIGINT                      NOT NULL UNIQUE REFERENCES products (id) ON DELETE SET NULL,
    discount_value INTEGER                     NOT NULL CHECK (discount_value >= 0 AND discount_value < 100) DEFAULT 0,
    start_date     TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    end_date       TIMESTAMP WITHOUT TIME ZONE NOT NULL
)
--changeset nikita.ryadnov:9
CREATE TABLE IF NOT EXISTS client_statistic
(
    client_id    BIGINT  NOT NULL PRIMARY KEY,
    cheque_count INTEGER NOT NULL DEFAULT 0,
    total_sum    NUMERIC(12, 2) CHECK (total_sum >= 0),
    discount_sum NUMERIC(12, 2) CHECK (discount_sum >= 0)
)
--changeset nikita.ryadnov:100
CREATE TABLE IF NOT EXISTS product_statistic
(
    product_id   BIGINT  NOT NULL PRIMARY KEY,
    cheque_count INTEGER NOT NULL DEFAULT 0,
    total_sum    NUMERIC(12, 2) CHECK (total_sum >= 0),
    discount_sum NUMERIC(12, 2) CHECK (discount_sum >= 0)
)