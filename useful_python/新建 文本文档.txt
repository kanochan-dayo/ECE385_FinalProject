#take hex input from user
hex = input("Enter a hex number: ")
#convert hex to decimal
import sys
dec = int(hex, 16)
number = dec-0x80000
number=number-1580
for j in range(0, number//1550+1):
    for i in range(0, number//1615+1):
        if(i*1615+j*1550==number):
            print("Number of 1615: ", i)
            print("Number of 1550: ", j)
            sys.exit()

print("Failed")