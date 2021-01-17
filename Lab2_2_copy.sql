CREATE DATABASE cargo_transportation;

\connect cargo_transportation

CREATE TABLE Driver (
    Driver_id int GENERATED ALWAYS AS IDENTITY,
    Driver_name text NOT NULL,
    Driver_phone varchar(15),
    Category text NOT NULL,
    PRIMARY KEY(Driver_id)
);

CREATE TABLE Transport (
    Transport_id int GENERATED ALWAYS AS IDENTITY,
    Licence_plate varchar(6) UNIQUE NOT NULL,
    Model text NOT NULL,
    Carrying_capacity real NOT NULL CHECK (Carrying_capacity > 0),
    Fuel_consumption real NOT NULL CHECK (Fuel_consumption > 0),
    Tank_volume real NOT NULL CHECK (Tank_volume > 0),
    PRIMARY KEY(Transport_id)
);

CREATE TABLE City (
    City_id int GENERATED ALWAYS AS IDENTITY,
    City_name text NOT NULL,
    PRIMARY KEY(City_id)
);

CREATE TABLE Trip (
    Trip_id int GENERATED ALWAYS AS IDENTITY,
    Transport_id int NOT NULL,
    Departure_city INT NOT NULL,
    Arrival_city int NOT NULL,
    Departure_date DATE NOT NULL,
    Arrival_date DATE NOT NULL CHECK (Arrival_date >= Departure_date),
    Travel_distance int NOT NULL CHECK (Travel_distance > 0),
    PRIMARY KEY(Trip_id),
    CONSTRAINT tr_transport
        FOREIGN KEY(Transport_id)
            REFERENCES Transport(Transport_id),
    CONSTRAINT tr_departure
        FOREIGN KEY(Departure_city)
            REFERENCES City(City_id),
    CONSTRAINT tr_arrival
        FOREIGN KEY(Arrival_city)
            REFERENCES City(City_id)
);

CREATE TABLE Trip_driver (
    Trip_id int NOT NULL,
    Driver_id int NOT NULL,
    PRIMARY KEY(Trip_id, Driver_id),
    CONSTRAINT td_trip
        FOREIGN KEY(Trip_id)
            REFERENCES Trip(Trip_id)
            ON DELETE CASCADE,
    CONSTRAINT td_driver
        FOREIGN KEY(Driver_id)
            REFERENCES Driver(Driver_id)
            ON DELETE CASCADE
);

CREATE TABLE Client (
    Client_id int GENERATED ALWAYS AS IDENTITY,
    Client_name text NOT NULL,
    Client_phone varchar(15),
    PRIMARY KEY(Client_id)
);

CREATE TABLE Orders (
    Order_id int GENERATED ALWAYS AS IDENTITY,
    Client_id int NOT NULL,
    Order_weight real NOT NULL DEFAULT 0,
    Order_cost money NOT NULL,
    PRIMARY KEY(Order_id),
    CONSTRAint ord_client
        FOREIGN KEY(Client_id)
            REFERENCES Client(Client_id)
            ON DELETE CASCADE
);

CREATE TABLE Cargo (
    Cargo_id int GENERATED ALWAYS AS IDENTITY,
    Cargo_name text NOT NULL,
    Cargo_weight real NOT NULL,
    Is_flammable BOOLEAN DEFAULT false,
    Is_fragile BOOLEAN DEFAULT false,
    Order_id int NOT NULL,
    PRIMARY KEY(Cargo_id),
    CONSTRAINT cargo_order
        FOREIGN KEY(Order_id)
            REFERENCES Orders(Order_id)
            ON DELETE CASCADE
);

CREATE TABLE Trip_order (
    Trip_id int NOT NULL,
    Order_id int NOT NULL,
    PRIMARY KEY(Trip_id, Order_id),
    CONSTRAINT to_trip
        FOREIGN KEY(Trip_id)
            REFERENCES Trip(Trip_id)
            ON DELETE CASCADE,
    CONSTRAINT to_order
        FOREIGN KEY(Order_id)
            REFERENCES Orders(Order_id)
            ON DELETE CASCADE
);