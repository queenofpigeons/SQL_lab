--индексы улучшают select

cargo_analysis=# explain analyze select * from trip where Travel_distance > 10;
                                                   QUERY PLAN
----------------------------------------------------------------------------------------------------------------
 Seq Scan on trip  (cost=0.00..68174.30 rows=999414 width=406) (actual time=0.060..422.729 rows=999987 loops=1)
   Filter: (travel_distance > 10)
   Rows Removed by Filter: 13
 Planning Time: 0.445 ms
 Execution Time: 476.920 ms
(5 rows)

cargo_analysis=# explain analyze select * from trip where Travel_distance > 5000;
                                                       QUERY PLAN
------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..61893.61 rows=94 width=406) (actual time=110.159..111.922 rows=0 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on trip  (cost=0.00..60884.21 rows=39 width=406) (actual time=103.568..103.569 rows=0 loops=3)
         Filter: (travel_distance > 5000)
         Rows Removed by Filter: 333333
 Planning Time: 0.401 ms
 Execution Time: 111.996 ms
(8 rows)

CREATE INDEX ON trip (Travel_distance);

cargo_analysis=# explain analyze select * from trip where Travel_distance > 10;
                                                   QUERY PLAN
----------------------------------------------------------------------------------------------------------------
 Seq Scan on trip  (cost=0.00..68177.00 rows=999630 width=406) (actual time=0.028..266.495 rows=999987 loops=1)
   Filter: (travel_distance > 10)
   Rows Removed by Filter: 13
 Planning Time: 0.326 ms
 Execution Time: 317.882 ms
(5 rows)

cargo_analysis=# explain analyze select * from trip where Travel_distance > 5000;
                                                           QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------
 Index Scan using trip_travel_distance_idx on trip  (cost=0.42..4.44 rows=1 width=406) (actual time=0.007..0.007 rows=0 loops=1)
   Index Cond: (travel_distance > 5000)
 Planning Time: 0.670 ms
 Execution Time: 0.031 ms
(4 rows)


cargo_analysis=# \di
                         List of relations
 Schema |           Name           | Type  |   Owner   |   Table
--------+--------------------------+-------+-----------+-----------
 public | orders_order_id_key      | index | alexandra | orders
 public | transport_pkey           | index | alexandra | transport
 public | trip_pkey                | index | alexandra | trip
 public | trip_travel_distance_idx | index | alexandra | trip
(4 rows)


cargo_analysis=# explain analyze select * from trip where Travel_distance > 10;
                                                                   QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------
 Index Scan using trip_travel_distance_idx on trip  (cost=0.42..84129.95 rows=999630 width=406) (actual time=0.039..509.020 rows=999987 loops=1)
   Index Cond: (travel_distance > 10)
 Planning Time: 0.392 ms
 Execution Time: 561.522 ms
(4 rows)

--фильтрация по 2 строкам

cargo_analysis=# explain analyze select * from trip where Travel_distance > 10 and order_id < 30 and order_id > 2;
                                                      QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..63968.77 rows=1 width=406) (actual time=20.615..149.387 rows=49 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on trip  (cost=0.00..62968.67 rows=1 width=406) (actual time=25.105..137.216 rows=16 loops=3)
         Filter: ((travel_distance > 10) AND (order_id < 30) AND (order_id > 2))
         Rows Removed by Filter: 333317
 Planning Time: 0.354 ms
 Execution Time: 149.448 ms
(8 rows)

CREATE INDEX ON trip (order_id);

cargo_analysis=# explain analyze select * from trip where Travel_distance > 10 and order_id < 30 and order_id > 2;
                                                         QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on trip  (cost=5.00..224.65 rows=56 width=406) (actual time=0.066..1.185 rows=49 loops=1)
   Recheck Cond: ((order_id < 30) AND (order_id > 2))
   Filter: (travel_distance > 10)
   Heap Blocks: exact=49
   ->  Bitmap Index Scan on trip_order_id_idx  (cost=0.00..4.99 rows=56 width=0) (actual time=0.026..0.027 rows=49 loops=1)
         Index Cond: ((order_id < 30) AND (order_id > 2))
 Planning Time: 0.931 ms
 Execution Time: 1.244 ms
(8 rows)


cargo_analysis=# explain analyze select * from trip where Travel_distance > 10 and order_id = 30 or order_id = 2;
                                                           QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------
 Append  (cost=0.42..33.06 rows=12 width=406) (actual time=0.137..0.207 rows=2 loops=1)
   ->  Index Scan using trip_order_id_idx on trip  (cost=0.42..16.50 rows=6 width=406) (actual time=0.136..0.139 rows=1 loops=1)
         Index Cond: (order_id = 2)
   ->  Index Scan using trip_order_id_idx on trip  (cost=0.42..16.50 rows=6 width=406) (actual time=0.063..0.064 rows=1 loops=1)
         Index Cond: (order_id = 30)
         Filter: (((travel_distance > 10) AND (order_id = 30)) OR (order_id = 2))
 Planning Time: 0.554 ms
 Execution Time: 0.303 ms
(8 rows)

-- с join

cargo_analysis=# explain analyze select * from trip join transport on trip.transport_id = transport.transport_id where Fuel_consumption = 8.49 and transport.carrying_capacity = 14668;
                                                             QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=8794.01..69731.64 rows=2 width=451) (actual time=37.457..39.028 rows=0 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Hash Join  (cost=7794.01..68731.44 rows=1 width=451) (actual time=32.128..32.129 rows=0 loops=3)
         Hash Cond: (trip.transport_id = transport.transport_id)
         ->  Parallel Seq Scan on trip  (cost=0.00..59843.67 rows=416667 width=406) (never executed)
         ->  Parallel Hash  (cost=7794.00..7794.00 rows=1 width=45) (actual time=31.876..31.876 rows=0 loops=3)
               Buckets: 1024  Batches: 1  Memory Usage: 0kB
               ->  Parallel Seq Scan on transport  (cost=0.00..7794.00 rows=1 width=45) (actual time=31.738..31.738 rows=0 loops=3)
                     Filter: ((fuel_consumption = '8.49'::double precision) AND (carrying_capacity = '14668'::double precision))
                     Rows Removed by Filter: 166667
 Planning Time: 0.568 ms
 Execution Time: 39.088 ms
(13 rows)

create index on transport (fuel_consumption , carrying_capacity);

cargo_analysis=# explain analyze select * from trip join transport on trip.transport_id = transport.transport_id where Fuel_consumption = 8.49 and transport.carrying_capacity = 14668;
                                                                                  QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1008.46..61946.08 rows=2 width=451) (actual time=12.512..13.691 rows=0 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Hash Join  (cost=8.45..60945.88 rows=1 width=451) (actual time=0.516..0.517 rows=0 loops=3)
         Hash Cond: (trip.transport_id = transport.transport_id)
         ->  Parallel Seq Scan on trip  (cost=0.00..59843.67 rows=416667 width=406) (actual time=0.024..0.024 rows=1 loops=3)
         ->  Hash  (cost=8.44..8.44 rows=1 width=45) (actual time=0.341..0.342 rows=0 loops=3)
               Buckets: 1024  Batches: 1  Memory Usage: 8kB
               ->  Index Scan using transport_fuel_consumption_carrying_capacity_idx on transport  (cost=0.42..8.44 rows=1 width=45) (actual time=0.341..0.341 rows=0 loops=3)
                     Index Cond: ((fuel_consumption = '8.49'::double precision) AND (carrying_capacity = '14668'::double precision))
 Planning Time: 0.866 ms
 Execution Time: 13.760 ms
(12 rows)

-- полнотекстовый поиск

SELECT * FROM orders WHERE to_tsvector('english', "order_description") @@ to_tsquery('swaggring');

explain analyze SELECT * FROM orders WHERE to_tsvector('english', "order_description") @@ to_tsquery('swaggring');
                                                          QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..129728.83 rows=2500 width=316) (actual time=38.806..2116.539 rows=137 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on orders  (cost=0.00..128478.83 rows=1042 width=316) (actual time=32.324..2108.537 rows=46 loops=3)
         Filter: (to_tsvector('english'::regconfig, order_description) @@ to_tsquery('swaggring'::text))
         Rows Removed by Filter: 166621
 Planning Time: 0.196 ms
 Execution Time: 2116.587 ms
(8 rows)

CREATE INDEX ON orders USING GIN (to_tsvector('english', "order_description"));

cargo_analysis=# explain analyze SELECT * FROM orders WHERE to_tsvector('english', "order_description") @@ to_tsquery('swaggring');
                                                             QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on orders  (cost=35.62..8432.52 rows=2500 width=316) (actual time=0.180..8.006 rows=137 loops=1)
   Recheck Cond: (to_tsvector('english'::regconfig, order_description) @@ to_tsquery('swaggring'::text))
   Heap Blocks: exact=137
   ->  Bitmap Index Scan on orders_to_tsvector_idx  (cost=0.00..35.00 rows=2500 width=0) (actual time=0.100..0.101 rows=137 loops=1)
         Index Cond: (to_tsvector('english'::regconfig, order_description) @@ to_tsquery('swaggring'::text))
 Planning Time: 2.201 ms
 Execution Time: 8.073 ms
(7 rows)

-- секционирование

CREATE TABLE IF NOT EXISTS
Trip_part (
    Trip_id int,
    Transport_id int,
    Departure_city text,
    Arrival_city text,
    Travel_distance int,
    Departure_date DATE ,
    Arrival_date DATE,
    Drivers text[],
    Model text,
    Carrying_capacity real,
    order_id int,
    order_weight int,
    cargo_arr text[]
) partition by range (order_weight);

CREATE TABLE IF NOT EXISTS trip_light_orders
  PARTITION OF Trip_part FOR VALUES FROM (0) TO (1000);

CREATE TABLE IF NOT EXISTS trip_heavy_orders
  PARTITION OF Trip_part FOR VALUES FROM (1000) TO (2001);

INSERT INTO Trip_part (Trip_id, Transport_id, Departure_city, Arrival_city, Travel_distance, Departure_date, Arrival_date, Drivers, Model, Carrying_capacity, order_id, order_weight, cargo_arr)
  SELECT * FROM trip;

CREATE INDEX ON Trip_part(order_weight);

EXPLAIN ANALYZE SELECT count(*) FROM trip WHERE Transport_id = 1 AND order_weight=1500;
                                                        QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=62927.10..62927.11 rows=1 width=8) (actual time=926.925..927.722 rows=1 loops=1)
   ->  Gather  (cost=1000.00..62927.10 rows=1 width=0) (actual time=926.921..927.717 rows=0 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Parallel Seq Scan on trip  (cost=0.00..61927.00 rows=1 width=0) (actual time=919.070..919.070 rows=0 loops=3)
               Filter: ((transport_id = 1) AND (order_weight = 1500))
               Rows Removed by Filter: 333333
 Planning Time: 0.114 ms
 Execution Time: 928.048 ms
(9 rows)

cargo_analysis=# EXPLAIN ANALYZE SELECT count(*) FROM Trip_part WHERE Transport_id = 1 AND order_weight=1500;
                                                                              QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=1986.18..1986.19 rows=1 width=8) (actual time=10.114..10.116 rows=1 loops=1)
   ->  Append  (cost=0.42..1986.18 rows=1 width=0) (actual time=10.109..10.109 rows=0 loops=1)
         ->  Index Scan using trip_heavy_orders_order_weight_idx on trip_heavy_orders  (cost=0.42..1986.17 rows=1 width=0) (actual time=10.107..10.108 rows=0 loops=1)
               Index Cond: (order_weight = 1500)
               Filter: (transport_id = 1)
               Rows Removed by Filter: 481
 Planning Time: 0.623 ms
 Execution Time: 10.266 ms
(8 rows)

-- индекс массив

EXPLAIN ANALYZE SELECT * FROM Trip WHERE Drivers @> ARRAY['Rebellious to his arm lies where it falls', 'But it reservd some quantity of choice', 'Is thought-sick at the act.'];
                                                                         QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..61885.43 rows=1 width=406) (actual time=944.530..1023.994 rows=1 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on trip  (cost=0.00..60885.33 rows=1 width=406) (actual time=988.135..1014.293 rows=0 loops=3)
         Filter: (drivers @> '{"Rebellious to his arm lies where it falls","But it reservd some quantity of choice","Is thought-sick at the act."}'::text[])
         Rows Removed by Filter: 333333
 Planning Time: 1.233 ms
 Execution Time: 1024.046 ms
(8 rows)

CREATE INDEX ON Trip USING gin(Drivers);

                                                                           QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on trip  (cost=40.00..44.01 rows=1 width=406) (actual time=1.814..1.820 rows=1 loops=1)
   Recheck Cond: (drivers @> '{"Rebellious to his arm lies where it falls","But it reservd some quantity of choice","Is thought-sick at the act."}'::text[])
   Heap Blocks: exact=1
   ->  Bitmap Index Scan on trip_drivers_idx  (cost=0.00..40.00 rows=1 width=0) (actual time=1.112..1.113 rows=1 loops=1)
         Index Cond: (drivers @> '{"Rebellious to his arm lies where it falls","But it reservd some quantity of choice","Is thought-sick at the act."}'::text[])
 Planning Time: 0.867 ms
 Execution Time: 3.086 ms
(7 rows)

-- json

EXPLAIN ANALYZE SELECT * FROM Orders WHERE order_details->'client' ? 'Together with all forms moods shapes of grief';

                                                       QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..25883.00 rows=500 width=316) (actual time=0.587..94.778 rows=126 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on orders  (cost=0.00..24833.00 rows=208 width=316) (actual time=4.361..87.489 rows=42 loops=3)
         Filter: ((order_details -> 'client'::text) ? 'Together with all forms moods shapes of grief'::text)
         Rows Removed by Filter: 166625
 Planning Time: 0.119 ms
 Execution Time: 94.830 ms
(8 rows)

CREATE INDEX ON orders USING gin((order_details->'client'));

                                                         QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on orders  (cost=15.88..1779.13 rows=500 width=316) (actual time=1.760..16.156 rows=126 loops=1)
   Recheck Cond: ((order_details -> 'client'::text) ? 'Together with all forms moods shapes of grief'::text)
   Heap Blocks: exact=126
   ->  Bitmap Index Scan on orders_expr_idx  (cost=0.00..15.75 rows=500 width=0) (actual time=0.082..0.083 rows=126 loops=1)
         Index Cond: ((order_details -> 'client'::text) ? 'Together with all forms moods shapes of grief'::text)
 Planning Time: 0.515 ms
 Execution Time: 16.246 ms
(7 rows)

