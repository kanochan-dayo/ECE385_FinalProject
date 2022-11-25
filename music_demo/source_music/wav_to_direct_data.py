wavefile=open('CHASE.wav','rb')
wavefile.seek(40)
data=wavefile.read()
data1=data[0:4]
# turn the data into a list of integers
number=data1[0]+data1[1]*256+data1[2]*256*256+data1[3]*256*256*256

print((number-3584))

data=data[4:4+number]

wavefile.close()
datafile=open('CHASE.dat','wb')
datafile.write(data)
datafile.close()
