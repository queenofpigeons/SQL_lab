import string

f = open("t_o.txt", 'w')

rows = 10000

for i in range(rows):
    f.write("%d,%d\n" % (i + 1, i + 1))