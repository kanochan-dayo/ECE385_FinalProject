# open 256data.txt
# read all lines

# for each line
#   split line into 3 values
#   convert each value to hex
#   print hex value

# close 256data.txt




input_file = "background.txt"
output_file = "background.mif"
out=open(output_file, "w")
out.write("DEPTH = 38400;\nWIDTH = 64;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n")
count=0;
temp="";
with open(input_file) as f:
    for line in f:
        line = line.strip()
        if len(line)==1:
            line="0"+line
        line= line.upper()
        temp=temp+line
        if(count%8==7):
            out.write(hex(count//8)[2:].zfill(4)+" : "+temp+";\n")
            temp=""
        count+=1

