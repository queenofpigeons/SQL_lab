import string

f = open("cities.txt", 'w')
cities = open("cities_old.txt", 'r')
city_lines = cities.readlines()

for i in range(len(city_lines)):
    f.write(str(i+1) + ',\"' + city_lines[i][:-1] + '\"\n')