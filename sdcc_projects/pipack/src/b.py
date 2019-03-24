from array import array
import os
file = 'msx.alf'
f = open(file, 'rb')
data = f.read()
f.close()
data2 = bytearray(data)
print (len(data))
for i in range(2*16*8+7,9*16*8+7):
	data2[i+7*16*8] = ~data2[i] & 0xff;
f = open(file, 'wb')
f.write(data2)