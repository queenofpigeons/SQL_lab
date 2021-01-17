import random
import string
import json

rows = 500000
header = 'Order_weight,Order_cost,Order_details,Cargo_arr'

f = open("orders.txt", 'w')
f_ord = open("orders_transport.txt", 'w')
things = open("hamlet_orders.txt", 'r')
lines = things.readlines()
#f.write(header + '\n')
for i in range(rows):
    f.write(str(i + 1) + ',')
    desc = lines[random.randint(0, len(lines) - 1)]
    f.write('\"' + desc[:-1] + '\",')
    weight = random.randint(1, 2000)
    f.write(str(weight) + ',')
    f_ord.write(str(weight))
    f.write(str(random.randint(1000, 50000)) + ',')

    name = lines[random.randint(0, len(lines) - 1)]
    is_flammable = bool(random.randint(0, 1))
    is_fragile = bool(random.randint(0, 1))

    f.write("{\"client\": \"%s\"\\, \"is_flammable\": \"%s\"\\, \"is_fragile\" : \"%s\"}" % (name[:-1], is_flammable, is_fragile))

    f.write(',{')
    f_ord.write(',{')
    number_of_cargo = (random.randint(1, 5))
    for j in range(number_of_cargo):
        line = lines[random.randint(0, len(lines) - 1)]
        f.write('\"' + line[:-1])
        if (j != number_of_cargo - 1):
            f.write('\"\\,')
        f_ord.write('\"' + line[:-1])
        if (j != number_of_cargo - 1):
            f_ord.write('\"\\,')
    f.write('\"}\n')
    f_ord.write('\"}\n')
