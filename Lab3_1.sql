CREATE TABLE Transport_test (
    Transport_id int UNIQUE,
    Licence_plate varchar(6) NOT NULL,
    Model text NOT NULL,
    Carrying_capacity real NOT NULL CHECK (Carrying_capacity > 0),
    Fuel_consumption real NOT NULL CHECK (Fuel_consumption > 0),
    Tank_volume real NOT NULL CHECK (Tank_volume > 0)
);

CREATE TABLE Orders (
    order_id int UNIQUE NOT NULL,
    order_description text,
    order_weight int NOT NULL CHECK (order_weight > 0),
    order_cost int NOT NULL CHECK (order_cost > 0),
    order_details jsonb NOT NULL,
    cargo_arr text[]
);

CREATE TABLE Trip (
    Trip_id int UNIQUE,
    Transport_id int NOT NULL,
    Departure_city text NOT NULL,
    Arrival_city text NOT NULL,
    Travel_distance int NOT NULL CHECK (Travel_distance > 0),
    Departure_date DATE NOT NULL,
    Arrival_date DATE NOT NULL CHECK (Arrival_date >= Departure_date),
    Drivers text[],
    Model text NOT NULL,
    Carrying_capacity real NOT NULL CHECK (Carrying_capacity > 0),
    order_id int NOT NULL,
    order_weight int NOT NULL CHECK (order_weight > 0),
    cargo_arr text[],
    PRIMARY KEY(Trip_id),
    CONSTRAINT tr_order
        FOREIGN KEY(Order_id)
            REFERENCES Orders(Order_id)
            ON DELETE CASCADE,
    CONSTRAINT tr_transport
        FOREIGN KEY(Transport_id)
            REFERENCES Transport(Transport_id)
);