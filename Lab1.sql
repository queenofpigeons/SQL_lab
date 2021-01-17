
--Общее количество сидений в моделях самолетов

SELECT a.model as model, count(distinct s.seat_no) as number_of_seats 
FROM Aircrafts a JOIN Seats s ON a.aircraft_code = s.aircraft_code 
GROUP BY model ORDER BY model;

-- Можно проверить запросом всех сидений для каждой отдельной модели

SELECT s.seat_no FROM aircrafts a 
JOIN seats s ON a.aircraft_code = s.aircraft_code 
WHERE a.model = 'Бомбардье CRJ-200' ORDER BY s.seat_no;

-- Номера и продолжительности рейсов дольше 7 часов, отсортированные по убыванию

SELECT flight_no, (actual_arrival - actual_departure) 
AS length, departure_airport, arrival_airport FROM flights 
WHERE status = 'Arrived' 
AND (actual_arrival - actual_departure) > '07:00:00' ORDER BY length DESC;

-- Название аэропорта с минимальным количеством вылетов

SELECT name, total_flight_count as min FROM 
(
	SELECT a.airport_name as name, count(f.departure_airport) as total_flight_count FROM flights f 
	JOIN airports a ON a.airport_code = f.departure_airport
	GROUP BY f.departure_airport, a.airport_name, a.city 
) count ORDER BY total_flight_count ASC LIMIT 1;

-- Название модели самолета, на котором летит каждый пассажир

SELECT t.passenger_name, a.model
FROM tickets t JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
JOIN flights f ON f.flight_id = tf.flight_id
JOIN aircrafts a ON f.aircraft_code = a.aircraft_code;

SELECT t.passenger_name, count(a.aircraft_code) as number_of_models
FROM tickets t JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
JOIN flights f ON f.flight_id = tf.flight_id
JOIN aircrafts a ON f.aircraft_code = a.aircraft_code
GROUP BY t.passenger_id, t.passenger_name;