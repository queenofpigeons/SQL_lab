import random
import string
import rstr

rows = 500000
header = 'licence_plate,Model,Carrying_capacity,Fuel_consuption,Tank_volume'
model = ['Volvo FM D12D420 6x4', 'ГАЗ ГАЗЕЛЬ 2704', 'IVECO EuroCargo ML120 EL17', 'ГАЗ 3307 3307', 'ГАЗ ГАЗЕЛЬ 2.3', 'Mercedes-Benz Actros']

f = open("transport.txt", 'w')
f_trip = open("trips_transport.txt", 'w')
#f.write(header + '\n')
for i in range(rows):
    f.write(str(i + 1) + ',')
    f.write(rstr.xeger(r'[A-Z]\d{3}[A-Z]{2}') + ',')
    i_model = random.randint(0, len(model) - 1)
    f.write(model[i_model] + ',')
    f_trip.write(model[i_model] + ',')
    capacity = str(random.randint(2000, 25000))
    f.write(capacity + ',')
    f_trip.write(capacity + ',')
    f.write("%.2f" % random.uniform(8, 25))
    f.write(',')
    f.write(str(random.randint(70, 1000)))
    f.write("\n")
    f_trip.write("\n")
