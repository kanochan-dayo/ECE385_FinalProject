wavefile=open('chase_48.wav','rb')
wavefile.seek(40)
data=wavefile.read()
data1=data[0:4]
# turn the data into a list of integers
number=data1[0]+data1[1]*256+data1[2]*256*256+data1[3]*256*256*256

data=data[4:4+number]
data1=data[1313257:1313259]




wavefile.close()
datafile=open('CHASE_48.dat','wb')
# datafile.write(data1)
# datafile.write(data1)
# datafile.write(data1)
datafile.write(data)
datafile.close()
