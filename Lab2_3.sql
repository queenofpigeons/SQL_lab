-- Исправим номер телефона определенного клиента

update client set client_phone = '303-79-56' where client_id = 3;

-- Выберем машины, в которых есть место для общего веса данного заказа, и которые не заняты в
-- заданное время

select departure_date, order_weight from trip tr
left join trip_order t_o on tr.trip_id = t_o.trip_id
left join orders o on t_o.order_id = o.order_id
where o.order_id = 6;

with t as (
    select t.transport_id, licence_plate, model, t.carrying_capacity from transport t
    left join trip tr on t.transport_id = tr.transport_id
    group by t.transport_id, licence_plate, model, carrying_capacity
    having max(arrival_date) < '2020-09-14'
)
select distinct t.transport_id, licence_plate, model from t
left join trip tr on t.transport_id = tr.transport_id
left join trip_order t_o on tr.trip_id = t_o.trip_id
left join orders o on t_o.order_id = o.order_id
where t.carrying_capacity >= 1200;

-- Выберем свободного водителя для определенного времени

select d.driver_id, driver_name from driver d
left join trip_driver td on d.driver_id = td.driver_id
left join trip tr on td.trip_id = tr.trip_id
left join transport t on t.transport_id = tr.transport_id
group by d.driver_id, driver_name
having max(arrival_date) < '2020-09-14';

-- Пусть определенный водитель уволился из компании. При удалении водителя из таблицы таблица поездок должна изменится

select d.driver_id, driver_name, tr.trip_id from driver d
left join trip_driver td on d.driver_id = td.driver_id
left join trip tr on td.trip_id = tr.trip_id
where d.driver_id = 1;

delete from driver where driver_id = 1;

select d.driver_id, driver_name, tr.trip_id from driver d
left join trip_driver td on d.driver_id = td.driver_id
left join trip tr on td.trip_id = tr.trip_id
where d.driver_id = 1;

-- Изменим вес одного груза и вес заказа

update cargo set cargo_weight = cargo_weight + 3
where cargo_id = 23;

update orders o set order_weight = order_weight + 3
from order_cargo oc
left join cargo c on c.cargo_id = oc.cargo_id
where oc.order_id = o.order_id and c.cargo_id = 23;