

create or replace function trips_by_city(cursor_name refcursor, city text)
    returns refcursor as $$
begin
    open cursor_name for (select trip_id, departure_city, arrival_city from trip where arrival_city = $2 or departure_city = $2);
    return cursor_name;
end;
$$ language plpgsql;

begin;
select trips_by_city('new_cur', '"Москва"');
fetch forward 5 FROM new_cur;
end;


create or replace function max_capacity_id(VARIADIC car_ids int[]) returns integer as $$
declare
	max_cap numeric = 0;
	max_id integer = -1;
    current_capacity integer = -1;
    current_id integer;
begin
	if (array_length(car_ids, 1) = 0) then
		begin
			raise exception 'Invalid number of arguments';
		end;
	end if;
	foreach current_id IN ARRAY car_ids LOOP
		select carrying_capacity
		into current_capacity
		from transport where transport_id = current_id;

		if (current_capacity > max_cap) then
			begin
				max_cap = current_capacity;
				max_id = current_id;
			end;
		end if;
	end loop;
    return max_id;
end;
$$ language plpgsql;

select max_capacity_id(1,2,3,4);
select transport_id, carrying_capacity from transport order by transport_id asc limit 4;
