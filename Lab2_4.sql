
--Этот уровень не поддерживается в postgresql, поэтому в данном сценарии грязного чтения не произойдет

-- Окно 1

BEGIN ISOLATION LEVEL READ UNCOMMITTED;
UPDATE cargo SET cargo_weight = 100 WHERE cargo_id = 1;
SELECT * FROM cargo WHERE cargo_id = 1;
END;

-- Окно 2

BEGIN ISOLATION LEVEL READ UNCOMMITTED;
SELECT * FROM cargo WHERE cargo_id = 1; -- не увидит 100
END;

-------------------

-- Окно 1

BEGIN ISOLATION LEVEL READ COMMITTED;
UPDATE cargo SET cargo_weight = 200 WHERE cargo_id = 1; --LSN1
END;

BEGIN ISOLATION LEVEL READ COMMITTED;
UPDATE cargo SET cargo_weight = 100 WHERE cargo_id = 1; --LSN2
END;

-- Окно 2

BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT * FROM cargo WHERE cargo_id = 1; -- увидит 100
-- после LSN1
SELECT * FROM cargo WHERE cargo_id = 1; -- увидит 200
-- после LSN2
SELECT * FROM cargo WHERE cargo_id = 1; -- увидит 100
END;

-------------------


-- Окно 1

BEGIN ISOLATION LEVEL REPEATABLE READ;
UPDATE cargo SET cargo_weight = 200 WHERE cargo_id = 2; --LSN1
END;

BEGIN ISOLATION LEVEL REPEATABLE READ;
UPDATE cargo SET cargo_weight = 300 WHERE cargo_id = 2; --LSN2
END;

-- Окно 2

BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM cargo WHERE cargo_id = 2; -- увидит 100
-- после LSN1
SELECT * FROM cargo WHERE cargo_id = 2; -- увидит 100
-- после LSN2
SELECT * FROM cargo WHERE cargo_id = 2; -- увидит 100
END;

-------------------

-- Окно 1

BEGIN ISOLATION LEVEL REPEATABLE READ;
INSERT INTO cargo(Cargo_name, Cargo_weight, Is_flammable, Is_fragile) values
('Личные вещи', 1000, DEFAULT, DEFAULT); --LSN1
END;

-- Окно 2

BEGIN ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM cargo;
-- после LSN1
SELECT * FROM cargo; -- должна увидеть личные вещи, но не увидит в postgresql
END;

-------------------

-- Окно 1

BEGIN ISOLATION LEVEL SERIALIZABLE;
INSERT INTO cargo(Cargo_name, Cargo_weight, Is_flammable, Is_fragile) values
('Личные вещи', 1000, DEFAULT, DEFAULT); --LSN1
END;

-- Окно 2

BEGIN ISOLATION LEVEL SERIALIZABLE;
SELECT * FROM cargo;
-- после LSN1
SELECT * FROM cargo; -- не видит ничего нового
END;
