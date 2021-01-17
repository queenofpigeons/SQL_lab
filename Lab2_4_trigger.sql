CREATE FUNCTION check_weight() RETURNS trigger AS $check_weight$
    DECLARE
        weight_delta real;
        insert_id int;
    BEGIN
        IF NEW IS NOT NULL THEN
            IF NEW.cargo_weight < 0 THEN
                RAISE EXCEPTION 'cargo cannot have a negative weight';
            END IF;
        END IF;
        IF (TG_OP = 'DELETE') THEN
            weight_delta = -1 * OLD.cargo_weight;
            insert_id = OLD.order_id;
        ELSIF (TG_OP = 'UPDATE') THEN
            weight_delta = NEW.cargo_weight - OLD.cargo_weight;
            insert_id = OLD.order_id;
        ELSIF (TG_OP = 'INSERT') THEN
            weight_delta = NEW.cargo_weight;
            insert_id = NEW.order_id;
        END IF;
        UPDATE orders SET order_weight = order_weight + weight_delta
        WHERE orders.order_id = insert_id;
        IF (TG_OP = 'DELETE') THEN
            RETURN OLD;
        END IF;
        RETURN NEW;
    END;
$check_weight$ LANGUAGE plpgsql;

CREATE FUNCTION check_order_weight() RETURNS trigger AS $check_order_weight$
    BEGIN
    RETURN NULL;
    end;
$check_order_weight$ LANGUAGE plpgsql;

CREATE trigger insert_ord_weight
BEFORE update of order_weight on orders
FOR EACH ROW
EXECUTE FUNCTION check_order_weight();


CREATE TRIGGER insert_weight
AFTER INSERT ON cargo
FOR EACH ROW
EXECUTE FUNCTION check_weight();

CREATE TRIGGER delete_weight
AFTER DELETE ON cargo
FOR EACH ROW
EXECUTE FUNCTION check_weight();

CREATE TRIGGER update_weight
AFTER UPDATE OF cargo_weight ON cargo
FOR EACH ROW
EXECUTE FUNCTION check_weight();

INSERT INTO cargo(Cargo_name, Cargo_weight, Is_flammable, Is_fragile, Order_id) VALUES
    ('Уличная Горелка', 17, true, false, 2),
    ('Уличная Горелка', 17, true, false, 2);

SELECT * FROM orders;

UPDATE cargo SET cargo_weight = 18 WHERE cargo_id = 1;

SELECT * FROM orders;

DELETE FROM cargo WHERE cargo_id = 1;

SELECT * FROM orders;

INSERT INTO cargo(Cargo_name, Cargo_weight, Is_flammable, Is_fragile, Order_id) VALUES
    ('Уличная Горелка', -17, true, false, 2);