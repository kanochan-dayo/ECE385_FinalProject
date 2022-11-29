
input_file = "background.txt"
output_file = "background.dat"

# Read the input file
f=open(input_file, "r")
f2=open(output_file, "wb")
# convert the file to binary
# convert string of hex value to bytes
# line="0"
line1="0"
# print(line1.upper())
count=0
for line in f:
    count=count+1
    line=line.strip()
    if len(line) ==1:
        line1="0"+line.upper()
    else:
        line1=line.upper()
    try:
        f2.write(bytes.fromhex(line1))
    except:
        print("Error")
        print(len(line))
        print(line1)
        print(count)
        break


