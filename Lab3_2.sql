./createuser test
---или
CREATE ROLE test;

grant SELECT on table transport to test;
grant SELECT (order_description, order_weight, cargo_arr), UPDATE (order_description, order_weight, cargo_arr) on table orders to test;
grant all privileges on table trip to test;

create view long_trips as
select departure_city, arrival_city, travel_distance, model, departure_date, arrival_date
from trip where travel_distance >= 3000;

create materialized view fuel_info as
select t.fuel_consumption, t.tank_volume, r.travel_distance
from transport t join trip r
on r.transport_id = t.transport_id;

create view order_info as
select order_weight, order_description, cargo_arr
from orders;

CREATE ROLE my_role;

GRANT SELECT, UPDATE ON order_info TO my_role;

GRANT my_role to test;

---User test

select * from order_info limit 5;

select order_cost from orders limit 5;

select model from transport limit 1;
update transport set model = 'aaaa' where transport_id = 1;