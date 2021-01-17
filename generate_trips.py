import random
import string
import rstr
import numpy as np

rows = 1000000
city_n = 1121
transport = 1000

f = open("trips.txt", 'w')
drivers = open("hamlet_orders.txt", 'r')
cities = open("cities_old.txt", 'r')
f_ord = open("orders_transport.txt", 'r')
ord_lines = f_ord.readlines()
f_trans = open("trips_transport.txt", 'r')
trans_lines = f_trans.readlines()
city_lines = cities.readlines()
lines = drivers.readlines()

b = np.random.randint(0,5000, size=(city_n,city_n))
dist = (b + b.T)/2

for i in range(rows):
    f.write(str(i + 1) + ',')
    transport_id = random.randint(1, transport)
    f.write(str(transport_id) + ',')
    dep = random.randint(1, city_n)
    arr = random.randint(1, city_n)
    f.write('\"' + city_lines[dep - 1][:-1] + '\"' + ',')
    f.write('\"' + city_lines[arr - 1][:-1] + '\"' + ',')
    f.write(str(int(dist[arr - 1, dep - 1])) + ',')
    year = random.randint(2000, 2021)
    month = random.randint(1, 12)
    day = random.randint(1, 25)
    duration = random.randint(1, 3)
    f.write("%d-%d-%d," % (year, month, day))
    f.write("%d-%d-%d," % (year, month, day + duration))
    f.write('{')
    number_of_drivers = (random.randint(1, 5))
    for j in range(number_of_drivers):
        line = lines[random.randint(0, len(lines) - 1)]
        f.write('\"' + line[:-1])
        if (j != number_of_drivers - 1):
            f.write('\"\\,')
    f.write('\"},')
    f.write(trans_lines[transport_id - 1][:-1])
    ord_id = random.randint(1, len(ord_lines))
    f.write(str(ord_id) + ',')
    f.write(ord_lines[ord_id - 1])
